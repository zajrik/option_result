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
	/// The `Result` class cannot be instantiated directly. use [Ok()], [Err()],
	/// or [Result.from()] to create instances of `Result` variants
	Result();

	/// Creates a `Result` from the given nullable `T` value
	///
	/// Creates:
	/// - [Ok] using the given `T` value if the given `T` value is not null.
	/// - [Err] using the given `E` value if the given `T` value is null.
	factory Result.from(T? value, E err) => switch (value) {
		null => Err(err),
		_ => Ok(value)
	};

	@override
	int get hashCode => switch (this) {
		Ok(value: T value) => Object.hash('Ok()', value),
		Err(value: E err) => Object.hash('Err()', err)
	};

	/// Compare equality between two `Result` values.
	///
	/// `Result` values are considered equal only if the value they hold is the
	/// same AND their runtime types are the same.
	///
	/// This means that `Ok<int, String>(1)` is not equal to `Ok<int, int>(1)` even
	/// though they are both `Ok(1)`.
	@override
	operator ==(Object other) => switch (other) {
		Ok(value: T value) when isOk() && compareRuntimeTypes(this, other) => value == unwrap(),
		Err(value: E err) when isErr() && compareRuntimeTypes(this, other) => err == unwrapErr(),
		_ => false
	};

	/// Shortcut to call [Result.unwrap()].
	///
	/// **Warning**: This is an *unsafe* operation. A [ResultError] will be thrown
	/// if this operator is used on a [None] value. You can take advantage of this
	/// safely via [propagateResult]/[propagateResultAsync] and their respective
	/// shortcuts ([ResultPropagateShortcut.~]/[ResultPropagateShortcutAsync.~]).
	///
	/// This is as close to analagous to Rust's `?` postfix operator for `Result`
	/// values as Dart can manage. There are no overrideable postfix operators in
	/// Dart, sadly, so this won't be as ergonomic as Rust but it's still nicer
	/// than calling [Result.unwrap()].
	///
	/// ```dart
	/// var foo = Ok(1);
	/// var bar = Ok(2);
	///
	/// print(~foo + ~bar); // prints: 3
	/// ```
	///
	/// **Note**: if you need to access fields or methods on the held value when
	/// using `~`, you'll need to use parentheses like so:
	///
	/// ```dart
	/// var res = Ok(1);
	///
	/// print((~res).toString());
	/// ```
	///
	/// Additionally, If you need to perform a bitwise NOT on the held value of
	/// a `Result`, you have a few choices:
	///
	/// ```dart
	/// var res = Ok(1);
	///
	/// print(~(~res)); // prints: -2
	/// print(~~res); // prints: -2
	/// print(~res.unwrap()); // prints: -2;
	/// ```
	T operator ~() => unwrap();

	/// Returns whether or not this result is an `Ok` result.
	bool isOk() => switch (this) {
		Ok() => true,
		Err() => false,
	};

	/// Returns whether or not this result is an `Err` result.
	bool isErr() => !isOk();

	/// Returns the held value of this `Result` if it is [Ok].
	///
	/// **Warning**: This method is *unsafe*. A [ResultError] will be thrown when
	/// this method is called if this `Result` is [Err].
	T unwrap() => switch (this) {
		Ok(value: T value) => value,
		Err() => throw ResultError('called `Result#unwrap()` on an `Err` value', original: this)
	};

	/// Returns the held value of this `Result` if it is [Ok], or the given value
	/// if this `Result` is [Err].
	T unwrapOr(T orValue) => switch (this) {
		Ok(value: T value) => value,
		Err() => orValue
	};

	/// Returns the held value of this `Result` if it is [Err].
	///
	/// **Warning**: This method is *unsafe*. A [ResultError] will be thrown when
	/// this method is called if this `Result` is [Ok].
	E unwrapErr() => switch (this) {
		Ok(value: T value) => throw ResultError(value),
		Err(value: E value) => value
	};

	/// Returns the held value of this `Result` if it is [Ok]. Throws a [ResultError]
	/// with the given `message` and held [Err] value if this `Result` is [Err].
	T expect(String message) => switch (this) {
		Ok(value: T value) => value,
		Err(value: E value) => throw ResultError('$message: $value', isExpected: true)
	};

	/// Returns the held value of this `Result` if it is [Err]. Throws a [ResultError]
	/// with the given `message` and held [Ok] value if this `Result` is [Ok].
	E expectErr(String message) => switch (this) {
		Ok(value: T value) => throw ResultError('$message: $value', isExpected: true),
		Err(value: E value) => value
	};

	/// Returns a `Result` value as [Err<U, E>] if this `Result` is [Err<T, E>],
	/// otherwise returns `other`.
	Result<U, E> and<U>(Result<U, E> other) => switch (this) {
		Ok() => other,
		Err(value: E value) => Err(value)
	};

	/// Returns a `Result` value as [Err<U, E>] if this `Result` is [Err<T, E>],
	/// otherwise calls `fn` with the held [Ok] value and returns the returned `Result`.
	Result<U, E> andThen<U>(Result<U, E> Function(T) fn) => switch (this) {
		Ok(value: T value) => fn(value),
		Err(value: E value) => Err(value)
	};

	/// Returns a `Result` value as [Ok<T, F>] if this `Result` is [Ok<T, E>],
	/// otherwise returns `other`.
	Result<T, F> or<F>(Result<T, F> other) => switch (this) {
		Ok(value: T value) => Ok(value),
		Err() => other
	};

	/// Returns a `Result` value as [Ok<T, F>] if this `Result` is [Ok<T, E>],
	/// otherwise calls `fn` with the held [Err] value and returns the returned `Result`.
	Result<T, F> orElse<F>(Result<T, F> Function(E) fn) => switch (this) {
		Ok(value: T value) => Ok(value),
		Err(value: E value) => fn(value)
	};

	/// Maps a `Result<T, E>` to a `Result<U, E>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Ok<U, E>] if this `Result` is [Ok<T, E>].
	/// - [Err<U, E>] if this `Result` is [Err<T, E>].
	Result<U, E> map<U>(U Function(T) mapFn) => switch (this) {
		Ok(value: T value) => Ok(mapFn(value)),
		Err(value: E value) => Err(value)
	};

	/// Maps a `Result<T, E>` to a `Result<T, F>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Ok<T, F>] if this [Result] is [Ok<T, E>].
	/// - [Err<T, F>] if this [Result] is [Err<T, E>].
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

/// Provides the `flatten()` method to [Option] type values that hold another [Option]
extension ResultFlatten<T, E> on Result<Result<T, E>, E> {
	/// Flattens a nested `Result` type value one level.
	///
	/// Returns:
	/// - [Ok<T, E>] if this `Result` is [Ok<Result<T, E>, E>]
	/// - [Err<T, E>] if this `Result` is [Err<Result<T, E>. E>]
	Result<T, E> flatten() => switch (this) {
		Ok(value: Result<T, E> value) => value,
		Err(value: E value) => Err(value)
	};
}
