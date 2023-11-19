part of option;

/// A type that represents the presence ([Some]) or absence ([None]) of a value.
///
/// Pattern matching is recommended for working with `Option` types.
///
/// ```dart
/// Option<int> foo = Some(42);
///
/// print(switch (foo) {
///   Some(value: var bar) => 'Some value: $bar',
///   None() => 'No value!'
/// });
/// ```
///
/// See also:
/// [Rust: `Option`](https://doc.rust-lang.org/std/option/enum.Option.html)
sealed class Option<T> {
	/// The `Option` class cannot be instantiated directly. use [Some()], [None()],
	/// or [Option.from()] to create instances of `Option` variants.
	const Option();

	/// Creates an `Option` from the given nullable `T` value.
	///
	/// Creates:
	/// - [Some] if the given value is not null.
	/// - [None] if the given value is null.
	factory Option.from(T? value) => switch (value) {
		null => None(),
		_ => Some(value)
	};

	@override
	int get hashCode => switch (this) {
		Some(:T v) => Object.hash('Some()', v),
		None() => Object.hash('None()', runtimeType)
	};

	/// Compare equality between two `Option` values.
	///
	/// `Option` values are considered equal if the values they hold are equal,
	/// or if they hold references to the same object ([identical()]).
	///
	/// Note that [None] values are always equal to one another. Their `T` type
	/// is elided implicitly.
	@override
	operator ==(Object other) => switch (other) {
		Some(:T v) when isSome() => identical(v, unwrap()) || v == unwrap(),
		None() when isNone() => true,
		_ => false
	};

	@override
	String toString() => switch (this) {
		Some(:T v) => 'Some($v)',
		None() => 'None()'
	};

	/// Shortcut to call [Option.unwrap()].
	///
	/// Allows calling an `Option` value like a function as a shortcut to unwrap the
	/// held value of the `Option`.
	///
	/// **Warning**: This is an *unsafe* operation. An [OptionError] will be thrown
	/// if this operation is used on a [None] value. You can take advantage of this
	/// safely via [catchOption]/[catchOptionAsync].
	///
	/// ```dart
	/// var foo = Some(1);
	/// var bar = Some(2);
	///
	/// print(foo() + bar()); // prints: 3
	/// ```
	///
	/// See also:
	/// [Rust: `Option::unwrap()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap)
	T call() => unwrap();

	/// Returns whether or not this `Option` holds a value ([Some]).
	///
	/// See also:
	/// [Rust: `Option::is_some()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.is_some)
	bool isSome() => switch (this) {
		Some() => true,
		None() => false
	};

	/// Returns whether or not this `Option` holds a value ([Some]) and the held
	/// value matches the given predicate.
	///
	/// Returns:
	/// - `true` if this `Option` is [Some] and `predicate` returns `true`.
	/// - `false` if this `Option` is [None], or `predicate` returns `false`
	///
	/// See also:
	/// [Rust: `Option::is_some_and()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.is_some_and)
	bool isSomeAnd(bool Function(T v) predicate) => switch (this) {
		Some(:T v) => predicate(v),
		None() => false
	};

	/// Returns whether or not this `Option` holds no value ([None]).
	///
	/// See also:
	/// [Rust: `Option::is_none()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.is_none)
	bool isNone() => !isSome();

	/// Returns the held value of this `Option` if it is [Some].
	///
	/// **Warning**: This method is *unsafe*. An [OptionError] will be thrown when
	/// this method is called if this `Option` is [None].
	///
	/// See also:
	/// [Rust: `Option::unwrap()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap)
	T unwrap() => switch (this) {
		Some(:T v) => v,
		None() => throw OptionError('called `Option#unwrap()` on a `None` value')
	};

	/// Returns the held value of this `Option` if it is [Some], or the given value
	/// if this `Option` is [None].
	///
	/// See also:
	/// [Rust: `Option::unwrap_or()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or)
	T unwrapOr(T orValue) => switch (this) {
		Some(:T v) => v,
		None() => orValue
	};

	/// Returns the held value of this `Option` if it is [Some], or returns the
	/// returned value from `elseFn` if this `Option` is [None].
	///
	/// See also:
	/// [Rust: `Option::unwrap_or_else()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or_else)
	T unwrapOrElse(T Function() elseFn) => switch (this) {
		Some(:T v) => v,
		None() => elseFn()
	};

	/// Returns the held value of this `Option` if it is [Some], or throws [OptionError]
	/// with the given `message` if this `Option` is [None].
	///
	/// See also:
	/// [Rust: `Option::expect()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.expect)
	T expect(String message) => switch (this) {
		Some(:T v) => v,
		None() => throw OptionError(message, isExpected: true)
	};

	/// Returns an [Iterable] of the held value.
	///
	/// Yields:
	/// - The held `T` value if [Some].
	/// - Nothing if [None].
	///
	/// See also:
	/// [Rust: `Option::iter()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.iter)
	Iterable<T> iter() sync* {
		switch (this) {
			case Some(:T v): yield v;
			case None(): return;
		}
	}

	/// Returns [None<U>] if this `Option` is [None<T>], otherwise returns `other`.
	///
	/// See also:
	/// [Rust: `Option::and()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.and)
	Option<U> and<U>(Option<U> other) => switch (this) {
		Some() => other,
		None() => None()
	};

	/// Returns [None<U>] if this `Option` is [None<T>], otherwise calls `fn` with
	/// the held value and returns the returned `Option`.
	///
	/// See also:
	/// [Rust: `Option::and_then()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.and_then)
	Option<U> andThen<U>(Option<U> Function(T v) fn) => switch (this) {
		Some(:T v) => fn(v),
		None() => None()
	};

	/// Returns this `Option` if this `Option` is [Some<T>], otherwise returns `other`.
	///
	/// See also:
	/// [Rust: `Option::or()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.or)
	Option<T> or(Option<T> other) => switch (this) {
		Some() => this,
		None() => other
	};

	/// Returns this `Option` if this `Option` is [Some<T>], otherwise calls `fn`
	/// and returns the returned `Option`.
	///
	/// See also:
	/// [Rust: `Option::or_else()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.or_else)
	Option<T> orElse(Option<T> Function() fn) => switch (this) {
		Some() => this,
		None() => fn()
	};

	/// Returns [Some] if exactly one of this `Option` and `other` is [Some], otherwise
	/// returns [None].
	///
	/// Returns:
	/// - This `Option` if this `Option` is [Some] and `other` is [None].
	/// - `other` if this `Option` is [None] and `other` is [Some].
	/// - [None] otherwise.
	///
	/// See also:
	/// [Rust: `Option::xor()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.xor)
	Option<T> xor(Option<T> other) => switch ((this, other)) {
		(Some(), None()) => this,
		(None(), Some()) => other,
		_ => None()
	};

	/// Calls the provided function with the contained value if this `Option` is [Some].
	///
	/// Returns this `Option`.
	///
	/// ```dart
	/// Option<int> foo = Some(1);
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
	/// [Rust: `Option::inspect()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.inspect)
	Option<T> inspect(void Function(T v) fn) {
		if (this case Some(:T v)) {
			fn(v);
		}

		return this;
	}

	/// Filters this `Option` based on the given `predicate` function.
	///
	/// Returns [None] if this `Option` is [None], otherwise calls `predicate` with
	/// the held value, returning:
	///
	/// - [Some<T>] if `predicate` returns `true`.
	/// - [None<T>] if `predicate` returns `false`.
	///
	/// See also:
	/// [Rust: `Option::filter()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.filter)
	Option<T> where(bool Function(T v) predicate) => switch (this) {
		Some(:T v) => predicate(v) ? this : None(),
		None() => this
	};

	/// Maps this `Option<T>` to an `Option<U>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Some<U>] if this `Option` is [Some<T>].
	/// - [None<U>] if this `Option` is [None].
	///
	/// See also:
	/// [Rust: `Option::map()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.map)
	Option<U> map<U>(U Function(T v) mapFn) => switch (this) {
		Some(:T v) => Some(mapFn(v)),
		None() => None()
	};

	/// Maps this `Option<T>` to an `Option<U>` using the given function with the
	/// held value if this `Option<T>` is [Some]. Otherwise returns the provided
	/// `orValue` as `Some(orValue)`.
	///
	/// Values passed for `orValue` are eagerly evaluated. Consider using [Option.mapOrElse()]
	/// to provide a default that will not be evaluated unless this `Option` is [None].
	///
	/// ```dart
	/// Option<int> a = Some(1);
	/// Option<int> b = None();
	///
	/// print(a.mapOr(5, (val) => val + 1).unwrap()); // prints: 2
	/// print(b.mapOr(5, (val) => val + 1).unwrap()); // prints: 5
	/// ```
	///
	/// **Note**: Unlike Rust's
	/// [Option::map_or()](https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or),
	/// this method returns an `Option` value. Given that [Option.map()] returns
	/// the mapped `Option` it just made sense for this method to do the same.
	///
	/// See also:
	/// [Rust: `Option::map_or()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or)
	Option<U> mapOr<U>(U orValue, U Function(T v) mapFn) => switch (this) {
		Some(:T v) => Some(mapFn(v)),
		None() => Some(orValue)
	};

	/// Maps this `Option<T>` to an `Option<U>` using the given `mapFn` function with
	/// the held value if this `Option` is [Some]. Otherwise returns the result of
	/// `orFn` as `Some(orFn())`.
	///
	/// `orFn` will only be evaluated if this `Option` is [None].
	///
	/// ```dart
	/// Option<int> a = Some(1);
	/// Option<int> b = None();
	///
	/// print(a.mapOrElse(() => 5, (val) => val + 1).unwrap()); // prints: 2
	/// print(b.mapOrElse(() => 5, (val) => val + 1).unwrap()); // prints: 5
	/// ```
	///
	/// **Note**: Unlike Rust's
	/// [Option::map_or_else()](https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or_else),
	/// this method returns an `Option` value. Given that [Option.map()] returns
	/// the mapped `Option` it just made sense for this method to do the same.
	///
	/// See also:
	/// [Rust: `Option::map_or_else()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or_else)
	Option<U> mapOrElse<U>(U Function() orFn, U Function(T v) mapFn) => switch (this) {
		Some(:T v) => Some(mapFn(v)),
		None() => Some(orFn())
	};

	/// Zips this `Option` with another `Option`, returning a [Record] of their
	/// held values.
	///
	/// Returns:
	/// - [Some<(T, U)>] if this `Option` is [Some<T>] and `other` is [Some<U>].
	/// - [None<(T, U)>] otherwise.
	///
	/// See: [OptionUnzip.unzip()] for reversing this operation.
	///
	/// See also:
	/// [Rust: `Option::zip()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.zip)
	Option<(T, U)> zip<U>(Option<U> other) => switch ((this, other)) {
		(Some(v: T a), Some(v: U b)) => Some((a, b)),
		_ => None()
	};

	/// Zips this `Option` with another `Option` using the given function.
	///
	/// Returns:
	/// - [Some<V>] if this `Option` is [Some<T>] and `other` is [Some<U>].
	/// - [None<V>] otherwise.
	///
	/// See also:
	/// [Rust: `Option::zip_with()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.zip_with)
	Option<V> zipWith<U, V>(Option<U> other, V Function(T v, U o) zipFn) => switch ((this, other)) {
		(Some(v: T a), Some(v: U b)) => Some(zipFn(a, b)),
		_ => None()
	};

	/// Converts this `Option<T>` into a [Result<T, E>] using the given `err` if [None].
	///
	/// Values passed for `err` are eagerly evaluated. Consider using [Option.okOrElse()]
	/// to provide an error value that will not be evaluated unless this `Option` is [None].
	///
	/// Returns:
	/// - [Ok<T, E>] if this `Option` is [Some<T>].
	/// - [Err<T, E>] using `err` if this `Option` is [None<T>].
	///
	/// See also:
	/// [Rust: `Option::ok_or()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.ok_or)
	Result<T, E> okOr<E>(E err) => switch (this) {
		Some(:T v) => Ok(v),
		None() => Err(err)
	};

	/// Converts this `Option<T>` into a [Result<T, E>] using the returned value
	/// from `elseFn` if [None].
	///
	/// `elseFn` will only be evaluated if this `Option` is [None].
	///
	/// Returns:
	/// - [Ok<T, E>] if this `Option` is [Some<T>].
	/// - [Err<T, E>] using the value returned by `elseFn` if this `Option` is [None<T>].
	///
	/// See also:
	/// [Rust: `Option::ok_or_else()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.ok_or_else)
	Result<T, E> okOrElse<E>(E Function() elseFn) => switch (this) {
		Some(:T v) => Ok(v),
		None() => Err(elseFn())
	};
}

/// A type that represents the presence of a value of type `T`.
///
/// Pattern matching is recommended for working with [Option] types.
///
/// ```dart
/// Option<int> foo = Some(42);
///
/// if (foo case Some(value: var bar)) {
///   print(bar);
/// }
/// ```
class Some<T> extends Option<T> {
	final T value;

	const Some(this.value);

	T get v => value;
	T get val => value;
}

/// A type that represents the absence of a value.
///
/// Pattern matching is recommended for working with [Option] types.
///
/// ```dart
/// Option<int> foo = None();
///
/// if (foo case None()) {
///   print('No value!');
/// }
/// ```
class None<T> extends Option<T> {
	const None();
}

/// Provides the `unzip()` method to [Option] type values that hold a [Record] of two values.
extension OptionUnzip<T, U> on Option<(T, U)> {
	/// Unzips this `Option` if this `Option` holds a [Record] of two values.
	///
	/// Returns:
	/// - `(Some<U>, Some<V>)` if this `Option` is [Some<(U, V)>].
	/// - `(None<U>, None<V>)` if this `Option` is [None<(U, V)>].
	///
	/// See also:
	/// [Rust: `Option::unzip()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unzip)
	(Option<T>, Option<U>) unzip() => switch (this) {
		Some(v: (T a, U b)) => (Some(a), Some(b)),
		None() => (None(), None())
	};
}

/// Provides the `flatten()` method to [Option] type values that hold another [Option].
extension OptionFlatten<T> on Option<Option<T>> {
	/// Flattens a nested `Option` type value one level.
	///
	/// Returns:
	/// - [Some<T>] if this `Option` is [Some<Option<T>>].
	/// - [None<T>] if this `Option` is [None<Option<T>>].
	///
	/// See also:
	/// [Rust: `Option::flatten()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.flatten)
	Option<T> flatten() => andThen(identity);
}

/// Provides the `transpose()` method to [Option] type values that hold a [Result].
extension OptionTranspose<T, E> on Option<Result<T, E>> {
	/// Transposes this [Option<Result<T, E>>] into a [Result<Option<T>, E>].
	///
	/// Returns:
	/// - [Ok<Some<T>, E>] if this `Option` is [Some<Ok<T, E>>].
	/// - [Err<T, E>] if this `Option` is [Some<Err<T, E>>].
	/// - [Ok<None<T>, E>] if this `Option` is [None<Result<T, E>>].
	///
	/// ```dart
	/// Option<Result<int, String>> a = Some(Ok(1));
	/// Result<Option<int>, String> b = Ok(Some(1));
	///
	/// print(a.transpose() == b); // prints: true
	/// ```
	///
	/// See also:
	/// [Rust: `Option::transpose()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.transpose)
	Result<Option<T>, E> transpose() => switch (this) {
		Some(v: Ok(:T v)) => Ok(Some(v)),
		Some(v: Err(:E e)) => Err(e),
		None() => Ok(None())
	};
}

/// Provides `call` functionality to [Future] values that complete with an [Option]
/// type value.
extension OptionFutureUnwrap<T> on Future<Option<T>> {
	/// Allows calling a `Future<Option<T>>` value like a function, transforming it
	/// into a Future that unwraps the returned `Option` value.
	///
	/// **Warning**: This is an *unsafe* operation. An [OptionError] will be thrown
	/// if this operation is used on a [Future] returning a [None] value when that
	/// [Future] completes. You can take advantage of this safely via [catchOptionAsync].
	///
	/// ```dart
	/// Future<Option<int>> optionReturn() async {
	///   return Some(1);
	/// }
	///
	/// int foo = await optionReturn()();
	///
	/// print(foo) // prints: 1
	/// ```
	///
	/// See also:
	/// [Rust: `Option::unwrap()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap)
	Future<T> call() async => (await this).unwrap();
}

/// Provides `call` functionality to [FutureOr] values that complete with an [Option]
/// type value.
extension OptionFutureOrUnwrap<T> on FutureOr<Option<T>> {
	/// Allows calling a `FutureOr<Option<T>>` value like a function, transforming it
	/// into a Future that unwraps the returned `Option` value.
	///
	/// **Warning**: This is an *unsafe* operation. An [OptionError] will be thrown
	/// if this operation is used on a [FutureOr] returning a [None] value when that
	/// [FutureOr] completes. You can take advantage of this safely via [catchOptionAsync].
	///
	/// ```dart
	/// FutureOr<Option<int>> optionReturn() {
	///   return Some(1);
	/// }
	///
	/// int foo = await optionReturn()();
	///
	/// print(foo) // prints: 1
	/// ```
	///
	/// See also:
	/// [Rust: `Option::unwrap()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap)
	Future<T> call() async => (await this).unwrap();
}
