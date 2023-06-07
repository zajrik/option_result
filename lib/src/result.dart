import 'package:equatable/equatable.dart';

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
sealed class Result<T, E> extends Equatable {
	/// Returns whether or not this result is an `Ok` result
	bool isOk() => switch (this) {
		Ok() => true,
		Err() => false,
	};

	/// Returns whether or not this result is an `Err` result
	bool isErr() => !isOk();

	/// Returns the contained [Ok] value. Throws a [ResultException] if this is an [Err] value
	T unwrap() => switch (this) {
		Ok(value: T value) => value,
		Err(value: E value) => throw ResultException(value)
	};

	/// Returns the contained [Ok] value, or the given value if this `Result` is an [Err] value
	T unwrapOr(T orValue) => switch (this) {
		Ok(value: T value) => value,
		Err() => orValue
	};

	/// Returns the contained [Err] value. Throws a [ResultException] if this is an [Ok] value
	E unwrapErr() => switch (this) {
		Ok(value: T value) => throw ResultException(value),
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

	@override
	List<T> get props => [value];
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

	@override
	List<E> get props => [value];
}

/// Represents an exception thrown by a [Result] type value
class ResultException implements Exception {
	final dynamic message;

	ResultException([this.message]);

	@override
	String toString() => switch (message) {
		null => 'OptionException',
		_ => 'OptionException: $message'
	};
}
