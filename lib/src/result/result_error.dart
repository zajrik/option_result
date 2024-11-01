part of result;

/// Represents an error thrown by a mishandled [Result] type value.
class ResultError<T, E> extends Error {
  /// The message this `ResultError` was created with.
  final dynamic message;

  /// The original unwrapped [Err] that triggered this `ResultError`, if any.
  final Result<T, E>? original;

  /// Whether or not this `ResultError` was thrown by [Result.expect()] or [Result.expectErr()].
  final bool isExpected;

  ResultError(this.message, {this.original, this.isExpected = false});

  @override
  String toString() {
    return switch (message) {
      null => 'ResultError',
      _ => 'ResultError: $message',
    };
  }
}
