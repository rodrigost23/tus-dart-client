/// Implementations of this interface are used to map an upload's fingerprint
/// with the corresponding upload URL. This functionality is used to allow
/// resuming uploads.
abstract class TusStore {
  /// Store a new fingerprint and its upload URL.
  void set(String fingerprint, Uri uri);

  /// Retrieve an upload's URL for a fingerprint. If no matching entry is found
  /// this method will return [null].
  Uri get(String fingerprint);

  /// Remove an entry from the store. Calling {@link #get(String)} with the same
  /// fingerprint will return [null]. If no entry exists for this fingerprint no
  /// exception should be thrown.
  void remove(String fingerprint);

  Uri operator [](String fingerprint) => get(fingerprint);
  void operator []=(String fingerprint, Uri uri) => set(fingerprint, uri);
}
