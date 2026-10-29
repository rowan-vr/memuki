import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';

void main() {
  group('generated IDs', () {
    test('are canonical UUIDv7', () {
      final id = NoteId.generate().value;
      expect(
        id,
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab]')),
      );
    });

    test('sort by creation time, to the millisecond', () {
      // UUIDv7 orders by its 48-bit millisecond timestamp; IDs created in the
      // same millisecond are in random order.
      final stamps = [
        for (var i = 0; i < 100; i++) NoteId.generate().value.substring(0, 13),
      ];
      expect([...stamps]..sort(), stamps);
    });
  });

  group('parse', () {
    test('normalizes to lowercase', () {
      const raw = '018F4A2B-1C3D-7E4F-8A5B-6C7D8E9F0A1B';
      expect(DeckId.parse(raw).value, raw.toLowerCase());
    });

    test('rejects non-UUIDs', () {
      expect(() => DeckId.parse('not-a-uuid'), throwsFormatException);
      expect(() => DeckId.parse(''), throwsFormatException);
    });
  });

  group('CardId.derive', () {
    final note = NoteId.parse('018f4a2b-1c3d-7e4f-8a5b-6c7d8e9f0a1b');
    final template = CardTemplateId.parse(
      '018f4a2b-1c3d-7e4f-8a5b-6c7d8e9f0a1c',
    );

    test('is deterministic', () {
      expect(CardId.derive(note, template), CardId.derive(note, template));
    });

    test('is a known value', () {
      // Fixed so the derivation cannot change without breaking card identity.
      expect(
        CardId.derive(note, template).value,
        'f335dcff-cbaf-8de0-b24e-d6b8f5a59f32',
      );
    });

    test('differs per template and per note', () {
      final other = CardTemplateId.generate();
      expect(CardId.derive(note, template), isNot(CardId.derive(note, other)));
      expect(
        CardId.derive(note, template),
        isNot(CardId.derive(NoteId.generate(), template)),
      );
    });

    test('is a UUIDv8 with the RFC 9562 variant', () {
      final id = CardId.derive(note, template).value;
      expect(
        id,
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-8[0-9a-f]{3}-[89ab]')),
      );
    });
  });

  group('ContentHash', () {
    test('is the SHA-256 hex digest', () {
      expect(
        ContentHash.of('abc'.codeUnits).value,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('parse rejects other strings', () {
      expect(() => ContentHash.parse('abc'), throwsFormatException);
    });
  });
}
