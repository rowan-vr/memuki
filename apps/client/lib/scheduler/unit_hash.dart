import 'dart:convert';

/// A number in [0, 1) derived from [seed]. Uses only arithmetic that is exact
/// in both native and web numbers, so every platform agrees.
double unitHash(String seed) {
  const modulus = 2147483647;
  var hash = 0;
  for (final byte in utf8.encode(seed)) {
    hash = (hash * 31 + byte) % modulus;
  }
  for (var i = 0; i < 3; i++) {
    hash = (hash * 48271) % modulus;
  }
  return hash / modulus;
}
