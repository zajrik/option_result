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
///
/// See also:
/// [Rust: `Result`](https://doc.rust-lang.org/std/result/enum.Result.html)
sealed class Result<T, E> {
	/// The `Result` class cannot be instantiated directly. use [Ok()], [Err()],
	/// or [Result.from()] to create instances of `Result` variants.
	const Result();

	/// Creates a `Result` from the given nullable `T` value.
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
	/// `Result` values are considered equal if the values they hold are equal,
	/// or if they hold references to the same object ([identical()]). When comparing
	/// [Ok] values, the type of `E` will be elided, and `T` will be elided when
	/// comparing [Err] values.
	///
	/// This means that [Ok<int, String>(1)] is equal to [Ok<int, int>(1)] and
	/// [Err<int, String>('foo')] is equal to [Err<bool, String>('foo')] because
	/// their held values are equatable and their irrelevant types are elided.
	@override
	operator ==(Object other) => switch (other) {
		Ok(value: T value) when isOk() => identical(value, unwrap()) || value == unwrap(),
		Err(value: E err) when isErr() => identical(err, unwrapErr()) || err == unwrapErr(),
		_ => false
	};

	@override
	String toString() => switch (this) {
		Ok(value: T value) => 'Ok($value)',
		Err(value: E err) => 'Err($err)'
	};

	/// Shortcut to call [Result.unwrap()].
	///
	/// **Warning**: This is an *unsafe* operation. A [ResultError] will be thrown
	/// if this operator is used on a [None] value. You can take advantage of this
	/// safely via [catchResult]/[catchResultAsync].
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
	///
	/// See also:
	/// [Rust: `Result::unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap)
	T operator ~() => unwrap();

	/// Returns whether or not this `Result` is [Ok].
	///
	/// See also:
	/// [Rust: `Result::is_ok()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_ok)
	bool isOk() => switch (this) {
		Ok() => true,
		Err() => false,
	};

	/// Returns whether or not this `Result` is [Ok] and that the held value matches
	/// the given predicate.
	///
	/// Returns:
	/// - `true` if this `Result` is [Ok] and `predicate` returns `true`.
	/// - `false` if this `Result` is [Err], or `predicate` returns `false`
	///
	/// See also:
	/// [Rust: `Result::is_ok_and()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_ok_and)
	bool isOkAnd(bool Function(T) predicate) => switch (this) {
		Ok(value: T value) => predicate(value),
		Err() => false
	};

	/// Returns whether or not this `Result` is [Err].
	///
	/// See also:
	/// [Rust: `Result::is_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_err)
	bool isErr() => !isOk();

	/// Returns whether or not this `Result` is [Err] and that the held error value
	/// matches the given predicate.
	///
	/// Returns:
	/// - `true` if this `Result` is [Err] and `predicate` returns `true`.
	/// - `false` if this `Result` is [Ok], or `predicate` returns `false`
	///
	/// See also:
	/// [Rust: `Result::is_err_and()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_err_and)
	bool isErrAnd(bool Function(E) predicate) => switch (this) {
		Ok() => false,
		Err(value: E value) => predicate(value)
	};

	/// Returns the held value of this `Result` if it is [Ok].
	///
	/// **Warning**: This method is *unsafe*. A [ResultError] will be thrown when
	/// this method is called if this `Result` is [Err].
	///
	/// See also:
	/// [Rust: `Result::unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap)
	T unwrap() => switch (this) {
		Ok(value: T value) => value,
		Err() => throw ResultError('called `Result#unwrap()` on an `Err` value', original: this)
	};

	/// Returns the held value of this `Result` if it is [Ok], or the given value
	/// if this `Result` is [Err].
	///
	/// See also:
	/// [Rust: `Result::unwrap_or()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_or)
	T unwrapOr(T orValue) => switch (this) {
		Ok(value: T value) => value,
		Err() => orValue
	};

	/// Returns the held value of this `Result` if it is [Ok], or returns the
	/// returned value from `elseFn` if this `Result` is [Err].
	///
	/// See also:
	/// [Rust: `Result::unwrap_or_else()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_or_else)
	T unwrapOrElse(T Function() elseFn) => switch (this) {
		Ok(value: T value) => value,
		Err() => elseFn()
	};

	/// Returns the held value of this `Result` if it is [Err].
	///
	/// **Warning**: This method is *unsafe*. A [ResultError] will be thrown when
	/// this method is called if this `Result` is [Ok].
	///
	/// See also:
	/// [Rust: `Result::unwrap_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_err)
	E unwrapErr() => switch (this) {
		Ok(value: T value) => throw ResultError(value),
		Err(value: E value) => value
	};

	/// Returns the held value of this `Result` if it is [Ok]. Throws a [ResultError]
	/// with the given `message` and held [Err] value if this `Result` is [Err].
	///
	/// See also:
	/// [Rust: `Result::expect()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.expect)
	T expect(String message) => switch (this) {
		Ok(value: T value) => value,
		Err(value: E value) => throw ResultError('$message: $value', isExpected: true)
	};

	/// Returns the held value of this `Result` if it is [Err]. Throws a [ResultError]
	/// with the given `message` and held [Ok] value if this `Result` is [Ok].
	///
	/// See also:
	/// [Rust: `Result::expect_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.expect_err)
	E expectErr(String message) => switch (this) {
		Ok(value: T value) => throw ResultError('$message: $value', isExpected: true),
		Err(value: E value) => value
	};

	/// Returns an [Iterable] of the held value.
	///
	/// Yields:
	/// - The held `T` value if [Ok].
	/// - Nothing if [Err].
	///
	/// See also:
	/// [Rust: `Result::iter()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.iter)
	Iterable<T> iter() sync* {
		switch (this) {
			case Ok(value: T value): yield value;
			case Err(): return;
		}
	}

	/// Returns a `Result` value as [Err<U, E>] if this `Result` is [Err<T, E>],
	/// otherwise returns `other`.
	///
	/// See also:
	/// [Rust: `Result::and()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.and)
	Result<U, E> and<U>(Result<U, E> other) => switch (this) {
		Ok() => other,
		Err(value: E value) => Err(value)
	};

	/// Returns a `Result` value as [Err<U, E>] if this `Result` is [Err<T, E>],
	/// otherwise calls `fn` with the held [Ok] value and returns the returned `Result`.
	///
	/// See also:
	/// [Rust: `Result::and_then()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.and_then)
	Result<U, E> andThen<U>(Result<U, E> Function(T) fn) => switch (this) {
		Ok(value: T value) => fn(value),
		Err(value: E value) => Err(value)
	};

	/// Returns a `Result` value as [Ok<T, F>] if this `Result` is [Ok<T, E>],
	/// otherwise returns `other`.
	///
	/// See also:
	/// [Rust: `Result::or()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.or)
	Result<T, F> or<F>(Result<T, F> other) => switch (this) {
		Ok(value: T value) => Ok(value),
		Err() => other
	};

	/// Returns a `Result` value as [Ok<T, F>] if this `Result` is [Ok<T, E>],
	/// otherwise calls `fn` with the held [Err] value and returns the returned `Result`.
	///
	/// See also:
	/// [Rust: `Result::or_else()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.or_else)
	Result<T, F> orElse<F>(Result<T, F> Function(E) fn) => switch (this) {
		Ok(value: T value) => Ok(value),
		Err(value: E value) => fn(value)
	};

	/// Calls the provided function with the contained value if this `Result` is [Ok].
	///
	/// ```dart
	/// Result<int, String> foo = Ok(1);
	///
	/// int bar = foo
	///   .map((value) => value + 2)
	///   .inspect((value) => print(value)) // prints: 3
	///   .unwrap();
	///
	/// print(bar); // prints: 3
	/// ```
	///
	/// See also:
	/// [Rust: `Result::inspect()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.inspect)
	Result<T, E> inspect(void Function(T) fn) {
		if (this case Ok(value: T v)) {
			fn(v);
		}

		return this;
	}

	/// Calls the provided function with the contained error value if this `Result`
	/// is [Err].
	///
	/// ```dart
	/// Result<int, String> foo = Err('foo');
	///
	/// String bar = foo
	///   .mapErr((value) => value + 'bar')
	///   .inspectErr((value) => print(value)) // prints: foobar
	///   .unwrapErr();
	///
	/// print(bar); // prints: foobar
	/// ```
	///
	/// See also:
	/// [Rust: `Result::inspect_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.inspect_err)
	Result<T, E> inspectErr(void Function(E) fn) {
		if (this case Err(value: E v)) {
			fn(v);
		}

		return this;
	}

	/// Maps a `Result<T, E>` to a `Result<U, E>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Ok<U, E>] if this `Result` is [Ok<T, E>].
	/// - [Err<U, E>] if this `Result` is [Err<T, E>].
	///
	/// See also:
	/// [Rust: `Result::map()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map)
	Result<U, E> map<U>(U Function(T) mapFn) => switch (this) {
		Ok(value: T value) => Ok(mapFn(value)),
		Err(value: E value) => Err(value)
	};

	/// Maps a `Result<T, E>` to a `Result<U, E>` using the given function with the
	/// held value if the `Result<T, E>` is [Ok]. Otherwise returns the provided
	/// `orValue` as `Ok(orValue)`.
	///
	/// Values passed for `orValue` are eagerly evaluated. Consider using [Result.mapOrElse()]
	/// to provide a default that will not be evaluated unless the `Result` is [Ok].
	///
	/// ```dart
	/// Result<int, String> a = Ok(1);
	/// Result<int, String> b = Err('foo');
	///
	/// print(a.mapOr(5, (val) => val + 1).unwrap()); // prints: 2
	/// print(b.mapOr(5, (val) => val + 1).unwrap()); // prints: 5
	/// ```
	///
	/// **Note**: Unlike Rust's
	/// [Result.map_or()](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or),
	/// this method returns a `Result` value. Given that [Result.map()] returns
	/// the mapped `Result` it just made sense for this method to do the same.
	///
	/// See also:
	/// [Rust: `Result::map_or()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or)
	Result<U, E> mapOr<U>(U orValue, U Function(T) mapFn) => switch (this) {
		Ok(value: T value) => Ok(mapFn(value)),
		Err() => Ok(orValue)
	};

	/// Maps a `Result<T, E>` to a `Result<U, E>` using the given `mapFn` function with
	/// the held value if the `Result` is [Ok]. Otherwise returns the result of
	/// `orFn` as `Ok(orFn())`.
	///
	/// `orFn` will only be evaluated if this `Result` is [Err].
	///
	/// ```dart
	/// Result<int, String> a = Ok(1);
	/// Result<int, String> b = Err('foo');
	///
	/// print(a.mapOrElse(() => 5, (val) => val + 1).unwrap()); // prints: 2
	/// print(b.mapOrElse(() => 5, (val) => val + 1).unwrap()); // prints: 5
	/// ```
	///
	/// **Note**: Unlike Rust's
	/// [Result.map_or_else()](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or_else),
	/// this method returns a `Result` value. Given that [Result.map()] returns
	/// the mapped `Result` it just made sense for this method to do the same.
	///
	/// See also:
	/// [Rust: `Result::map_or_else()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or_else)
	Result<U, E> mapOrElse<U>(U Function() orFn, U Function(T) mapFn) => switch (this) {
		Ok(value: T value) => Ok(mapFn(value)),
		Err() => Ok(orFn())
	};

	/// Maps a `Result<T, E>` to a `Result<T, F>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Ok<T, F>] if this [Result] is [Ok<T, E>].
	/// - [Err<T, F>] if this [Result] is [Err<T, E>].
	///
	/// See also:
	/// [Rust: `Result::map_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_err)
	Result<T, F> mapErr<F>(F Function(E) mapFn) => switch (this) {
		Ok(value: T value) => Ok(value),
		Err(value: E value) => Err(mapFn(value))
	};

	/// Converts this `Result<T, E>` into an [Option<T>], discarding the held error
	/// value if this is [Err].
	///
	/// Returns:
	/// - [Some<T>] if this `Result` is [Ok<T, E>].
	/// - [None<T>] if this `Result` is [Err<T, E>].
	///
	/// See also:
	/// [Rust: `Result::ok()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.ok)
	Option<T> ok() => switch (this) {
		Ok(value: T value) => Some(value),
		Err() => None()
	};

	/// Converts this `Result<T, E>` into an [Option<E>], discarding the held value
	/// if this is [Ok].
	///
	/// Returns:
	/// - [Some<E>] if this `Result` is [Err<T, E>].
	/// - [None<E>] if this `Result` is [Ok<T, E>].
	///
	/// See also:
	/// [Rust: `Result::err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.err)
	Option<E> err() => switch (this) {
		Ok() => None(),
		Err(value: E value) => Some(value)
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

	const Ok(this.value);
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

	const Err(this.value);
}

/// Provides the `flatten()` method to [Result] type values that hold another [Result].
extension ResultFlatten<T, E> on Result<Result<T, E>, E> {
	/// Flattens a nested `Result` type value one level.
	///
	/// Returns:
	/// - [Ok<T, E>] if this `Result` is [Ok<Result<T, E>, E>]
	/// - [Err<T, E>] if this `Result` is [Err<Result<T, E>. E>]
	///
	/// See also:
	/// [Rust: `Result::flatten()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.flatten)
	Result<T, E> flatten() => switch (this) {
		Ok(value: Result<T, E> value) => value,
		Err(value: E value) => Err(value)
	};
}

/// Provides the `transpose()` method to [Result] type values that hold an [Option] value.
extension ResultTranspose<T, E> on Result<Option<T>, E> {
	/// Transposes this `Result<Option<T>, E>` into an [Option<Result<T, E>>].
	///
	/// Returns:
	/// - [Some<Ok<T, E>>] if this `Result` is [Ok<Some<T>, E>].
	/// - [None<Result<T, E>>] if this `Result` is [Ok<None<T>, E>].
	/// - [Some<Err<T, E>>] if this `Result` is [Err<Option<T>, E>].
	///
	/// ```dart
	/// Result<Option<int>, String> a = Ok(Some(1));
	/// Option<Result<int, String>> b = Some(Ok(1));
	///
	/// print(a.transpose() == b); // prints: true
	/// ```
	///
	/// See also:
	/// [Rust: `Result::transpose()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.transpose)
	Option<Result<T, E>> transpose() => switch (this) {
		Ok(value: Some(value: T value)) => Some(Ok(value)),
		Ok(value: None()) => None(),
		Err(value: E value) => Some(Err(value))
	};
}
