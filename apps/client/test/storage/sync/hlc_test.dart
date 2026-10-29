import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/storage/sync/hlc.dart';

const _node = '0123456789abcdef';
const _other = 'fedcba9876543210';

void main() {
  group('Hlc', () {
    test('formats as fixed-width hex and parses back', () {
      final hlc = Hlc(0x019a2f6c8e40, 3, _node);
      expect(hlc.toString(), '019a2f6c8e40-0003-$_node');
      expect(Hlc.parse(hlc.toString()), hlc);
    });

    test('text order matches timestamp order', () {
      final stamps = [
        Hlc(1, 0, _other),
        Hlc(1, 1, _node),
        Hlc(2, 0, _node),
        Hlc(0x10, 0, _node),
        Hlc(0x100, 0xffff, _node),
      ];
      final byText = [...stamps]
        ..sort((a, b) => a.toString().compareTo(b.toString()));
      expect(byText, stamps);
    });

    test('ties between devices break on the node', () {
      expect(Hlc(5, 0, _other) > Hlc(5, 0, _node), isTrue);
    });

    test('rejects malformed values', () {
      expect(() => Hlc.parse('nope'), throwsFormatException);
      expect(() => Hlc(-1, 0, _node), throwsRangeError);
      expect(() => Hlc(0, 0x10000, _node), throwsRangeError);
      expect(() => Hlc(0, 0, 'ABC'), throwsArgumentError);
    });

    test('generated nodes are valid and distinct', () {
      final a = Hlc.generateNode();
      expect(Hlc(0, 0, a).node, a);
      expect(Hlc.generateNode(), isNot(a));
    });
  });

  group('HlcClock', () {
    late DateTime now;
    late HlcClock clock;

    setUp(() {
      now = DateTime.utc(2026, 10, 29);
      clock = HlcClock(_node, now: () => now);
    });

    test('follows the wall clock', () {
      final first = clock.tick();
      now = now.add(const Duration(seconds: 1));
      final second = clock.tick();
      expect(second.millis, now.millisecondsSinceEpoch);
      expect(second.counter, 0);
      expect(second > first, isTrue);
    });

    test('counts within a millisecond and when the wall clock goes back', () {
      final first = clock.tick();
      final second = clock.tick();
      now = now.subtract(const Duration(hours: 1));
      final third = clock.tick();
      expect([second.counter, third.counter], [1, 2]);
      expect(third.millis, first.millis);
    });

    test('borrows the next millisecond when the counter runs out', () {
      clock = HlcClock(
        _node,
        last: Hlc(now.millisecondsSinceEpoch, Hlc.maxCounter, _node),
        now: () => now,
      );
      final next = clock.tick();
      expect(next.millis, now.millisecondsSinceEpoch + 1);
      expect(next.counter, 0);
    });

    test('continues after the last timestamp of a previous run', () {
      final last = Hlc(now.millisecondsSinceEpoch + 5000, 7, _node);
      clock = HlcClock(_node, last: last, now: () => now);
      expect(clock.tick() > last, isTrue);
    });

    test('orders local changes after received ones', () {
      final remote = Hlc(now.millisecondsSinceEpoch + 60000, 4, _other);
      clock.receive(remote);
      final next = clock.tick();
      expect(next > remote, isTrue);
      expect(next.node, _node);
    });

    test('receiving an older or equal timestamp still advances', () {
      final local = clock.tick();
      clock.receive(Hlc(local.millis, 9, _other));
      expect(clock.tick().counter, 11);
      clock.receive(Hlc(0, 0, _other));
      expect(clock.tick().counter, 13);
    });

    test('receiving when the wall clock is ahead uses the wall clock', () {
      clock.tick();
      now = now.add(const Duration(minutes: 1));
      clock.receive(Hlc(0, 0, _other));
      final next = clock.tick();
      expect(next.millis, now.millisecondsSinceEpoch);
      expect(next.counter, 1);
    });

    test('rejects a timestamp too far ahead of the wall clock', () {
      final before = clock.tick();
      final limit = now.add(HlcClock.maxSkew).millisecondsSinceEpoch;
      expect(
        () => clock.receive(Hlc(limit + 1, 0, _other)),
        throwsA(isA<ClockSkewException>()),
      );
      expect(clock.last, before);

      clock.receive(Hlc(limit, 0, _other));
      expect(clock.last.millis, limit);
    });
  });
}
