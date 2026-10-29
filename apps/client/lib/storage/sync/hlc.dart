import 'dart:math';

import 'package:flutter/foundation.dart';

/// A hybrid logical clock timestamp: wall-clock milliseconds, a counter for
/// changes within the same millisecond, and the ID of the device that made
/// the change.
///
/// Timestamps order changes across devices even when their clocks disagree.
/// Their text form is fixed-width hex (`<12 ms>-<4 counter>-<16 node>`), so
/// ordering text compares in the same order as the timestamps.
@immutable
class Hlc implements Comparable<Hlc> {
  Hlc(this.millis, this.counter, this.node) {
    if (millis < 0 || millis > maxMillis) {
      throw RangeError.range(millis, 0, maxMillis, 'millis');
    }
    if (counter < 0 || counter > maxCounter) {
      throw RangeError.range(counter, 0, maxCounter, 'counter');
    }
    if (!_node.hasMatch(node)) {
      throw ArgumentError.value(node, 'node', 'must be 16 lowercase hex');
    }
  }

  factory Hlc.parse(String value) {
    final match = _format.firstMatch(value);
    if (match == null) throw FormatException('Not an HLC timestamp', value);
    return Hlc(
      int.parse(match[1]!, radix: 16),
      int.parse(match[2]!, radix: 16),
      match[3]!,
    );
  }

  static const maxMillis = 0xffffffffffff;
  static const maxCounter = 0xffff;

  static final _node = RegExp(r'^[0-9a-f]{16}$');
  static final _format = RegExp(
    r'^([0-9a-f]{12})-([0-9a-f]{4})-([0-9a-f]{16})$',
  );

  final int millis;
  final int counter;

  /// The device that made the change, as 16 lowercase hex characters.
  final String node;

  /// A random node ID for a new installation.
  static String generateNode() {
    final random = Random.secure();
    return [
      for (var i = 0; i < 8; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
  }

  @override
  int compareTo(Hlc other) => toString().compareTo(other.toString());

  bool operator >(Hlc other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.millis == millis &&
      other.counter == counter &&
      other.node == node;

  @override
  int get hashCode => Object.hash(millis, counter, node);

  @override
  String toString() =>
      '${millis.toRadixString(16).padLeft(12, '0')}-'
      '${counter.toRadixString(16).padLeft(4, '0')}-$node';
}

/// Issues [Hlc] timestamps for one device. Timestamps only increase, even if
/// the wall clock goes backwards.
class HlcClock {
  HlcClock(this.node, {Hlc? last, DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _millis = last?.millis ?? 0,
      _counter = last?.counter ?? 0;

  final String node;
  final DateTime Function() _now;
  int _millis;
  int _counter;

  /// A timestamp for a local change, later than every timestamp issued or
  /// received before.
  Hlc tick() {
    final wall = _now().millisecondsSinceEpoch;
    if (wall > _millis) {
      _millis = wall;
      _counter = 0;
    } else {
      _advanceCounter();
    }
    return Hlc(_millis, _counter, node);
  }

  /// Merges a timestamp received from another device, so later local
  /// timestamps order after it.
  void receive(Hlc remote) {
    final wall = _now().millisecondsSinceEpoch;
    if (wall > _millis && wall > remote.millis) {
      _millis = wall;
      _counter = 0;
    } else if (remote.millis > _millis) {
      _millis = remote.millis;
      _counter = remote.counter;
      _advanceCounter();
    } else if (remote.millis == _millis) {
      _counter = max(_counter, remote.counter);
      _advanceCounter();
    } else {
      _advanceCounter();
    }
  }

  /// When the counter is exhausted, borrows the next millisecond.
  void _advanceCounter() {
    if (_counter == Hlc.maxCounter) {
      _millis++;
      _counter = 0;
    } else {
      _counter++;
    }
  }
}
