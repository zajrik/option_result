part of result;

/// Represents an error thrown by a mishandled [Result] type value
class ResultError<T, E> extends Error {
	final dynamic message;
	final Result<T, E>? original;

	ResultError([this.message, this.original]);

	@override
	String toString() => switch (message) {
		null => 'ResultError',
		_ => 'ResultError: $message'
	};
}
