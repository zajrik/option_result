part of result;

/// A type that represents the result of something, either success ([Ok]) or failure ([Err]).
///
/// A `Result` type holds either a value of type `T`, or an error value of type `E`.
///
/// Pattern matching is recommended for interacting with `Result` types.
///
/// ```dart
/// Result<int, String> foo = Ok(42);
///
/// print(switch (foo) {
///   Ok(value: var bar) => 'Ok value: $bar',
///   Err(value: var err) => 'Error value: $err'
/// });
/// ```
sealed class Result<T, E> {
	/// The `Result` class cannot be instantiated directly. use [Ok], [Error], or
	/// [Result.from] to create instances of `Result` variants
	Result();

	/// Creates a `Result` from the given nullable `T` value
	///
	/// Creates:
	/// - [Ok] using the given `T` value if the given `T` value is not null
	/// - [Err] using the given `E` value if the given `T` value is null
	factory Result.from(T? value, E err) => switch (value) {
		null => Err(err),
		_ => Ok(value)
	};

	/// Compare equality between two `Result` values.
	///
	/// `Result` values are considered equal only if the value they hold is the
	/// same AND their runtime types are the same.
	///
	/// This means that `Ok<int, String>(1)` is not equal to `Ok<int, int>(1)` even
	/// though they are both `Ok(1)`
	@override
	operator ==(Object other) => switch (other) {
		Ok(value: T value) when isOk() && compareRuntimeTypes(this, other) => value == unwrap(),
		Err(value: E err) when isErr() && compareRuntimeTypes(this, other) => err == unwrapErr(),
		_ => false
	};

	@override
	int get hashCode => switch (this) {
		Ok(value: T value) => Object.hash('Ok()', value),
		Err(value: E err) => Object.hash('Err()', err)
	};

	/// Returns whether or not this result is an `Ok` result
	bool isOk() => switch (this) {
		Ok() => true,
		Err() => false,
	};

	/// Returns whether or not this result is an `Err` result
	bool isErr() => !isOk();

	/// Returns the held [Ok] value.
	///
	/// Throws a [ResultError] if this is an [Err] value
	T unwrap() => switch (this) {
		Ok(value: T value) => value,
		Err() => throw ResultError('called `Result#unwrap()` on an `Err` value', this)
	};

	/// Returns the held [Ok] value, or the given value if this `Result` is an [Err] value
	T unwrapOr(T orValue) => switch (this) {
		Ok(value: T value) => value,
		Err() => orValue
	};

	/// Returns the held [Err] value. Throws a [ResultError] if this is an [Ok] value
	E unwrapErr() => switch (this) {
		Ok(value: T value) => throw ResultError(value),
		Err(value: E value) => value
	};

	/// Maps a `Result<T, E>` to a `Result<U, E>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Ok<U, E>] if this `Result` is [Ok<T, E>]
	/// - [Err<U, E>] if this `Result` is [Err<T, E>]
	Result<U, E> map<U>(U Function(T) mapFn) => switch (this) {
		Ok(value: T value) => Ok(mapFn(value)),
		Err(value: E value) => Err(value)
	};

	/// Maps a `Result<T, E>` to a `Result<T, F>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Ok<T, F>] if this [Result] is [Ok<T, E>]
	/// - [Err<T, F>] if this [Result] is [Err<T, E>]
	Result<T, F> mapErr<F>(F Function(E) mapFn) => switch (this) {
		Ok(value: T value) => Ok(value),
		Err(value: E value) => Err(mapFn(value))
	};
}

/// A type that represents the successful [Result] of something.
///
/// Pattern matching is recommended for interacting with [Result] types.
///
/// ```dart
/// Result<int, String> foo = Ok(42);
///
/// if (foo case Ok(value: var bar)) {
///   print('Ok value: $bar');
/// }
/// ```
class Ok<T, E> extends Result<T, E> {
	final T value;

	Ok(this.value);
}

/// A type that represents the failure [Result] of something.
///
/// Pattern matching is recommended for interacting with [Result] types.
///
/// ```dart
/// Result<int, String> foo = Err('panic!');
///
/// if (foo case Err(value: var err)) {
///   print('Error value: $err');
/// }
/// ```
class Err<T, E> extends Result<T, E> {
	final E value;

	Err(this.value);
}
