part of result_option;

/// `Result` is a type that represents either success ([Ok]) or failute ([Err]).
/// A `Result` type holds either a value of type `T`, or an error value of type `E`.
///
/// Pattern matching is recommended for interacting with `Result` types.
///
/// ```dart
/// Result<int, String> foo = Ok(42);
///
/// print(switch (foo) {
///   Ok(value: bar) => 'Ok value: $bar',
///   Err(value: err) => 'Error value: $err'
/// });
/// ```
sealed class Result<T, E> {
	/// The `Result` class cannot be instantiated directly. use [Ok], [Error], or
	/// [Result.from] to create instances of `Result` variants
	Result();

	/// Compare equality between two `Result` values. `Result` values are considered
	/// equal only if the value they hold is the same AND their runtime types are the same.
	///
	/// This means that a `Ok<int, String>(1)` is not equal to `Ok<int, int>(1)` even though they
	/// are both `Ok(1)`
	@override
	operator ==(Object other) => switch (other) {
		Ok(value: T value) when isOk() && _compareRuntimeTypes(this, other) => value == unwrap(),
		Err(value: E err) when isErr() && _compareRuntimeTypes(this, other) => err == unwrapErr(),
		_ => false
	};

	@override
	int get hashCode => switch (this) {
		Ok(value: T value) => value.hashCode,
		Err(value: E err) => err.hashCode
	};

	/// Creates an [Ok] result from the given nullable `T` value. If the given value
	/// is null, an [Err] result will be created instead using the given `E` value
	factory Result.from(T? value, E err) => switch (value) {
		null => Err(err),
		_ => Ok(value)
	};

	/// Returns whether or not this result is an `Ok` result
	bool isOk() => switch (this) {
		Ok() => true,
		Err() => false,
	};

	/// Returns whether or not this result is an `Err` result
	bool isErr() => !isOk();

	/// Returns the contained [Ok] value. Throws a [ResultError] if this is an [Err] value
	T unwrap() => switch (this) {
		Ok(value: T value) => value,
		Err() => throw ResultError('called `Result#unwrap()` on an `Err` value', this)
	};

	/// Returns the contained [Ok] value, or the given value if this `Result` is an [Err] value
	T unwrapOr(T orValue) => switch (this) {
		Ok(value: T value) => value,
		Err() => orValue
	};

	/// Returns the contained [Err] value. Throws a [ResultError] if this is an [Ok] value
	E unwrapErr() => switch (this) {
		Ok(value: T value) => throw ResultError(value, this),
		Err(value: E value) => value
	};
}

/// Contains the success value of a [Result]
///
/// Pattern matching is recommended for interacting with [Result] types.
///
/// ```dart
/// Result<int, String> foo = Ok(42);
///
/// if (foo case Ok(value: bar)) {
///   print('Ok value: $bar');
/// }
/// ```
class Ok<T, E> extends Result<T, E> {
	final T value;

	Ok(this.value);
}

/// Contains the error value of a [Result].
///
/// Pattern matching is recommended for interacting with [Result] types.
///
/// ```dart
/// Result<int, String> foo = Err('panic!');
///
/// if (foo case Err(value: err)) {
///   print('Error value: $err');
/// }
/// ```
class Err<T, E> extends Result<T, E> {
	final E value;

	Err(this.value);
}

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
