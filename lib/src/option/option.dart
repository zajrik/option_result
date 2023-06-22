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
sealed class Option<T> {
	/// The `Option` class cannot be instantiated directly. use [Some()], [None()],
	/// or [Option.from()] to create instances of `Option` variants.
	Option();

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
		Some(value: T value) => Object.hash('Some()', value),
		None() => Object.hash('None()', runtimeType)
	};

	/// Compare equality between two `Option` values.
	///
	/// `Option` values are considered equal only if the value they hold is the
	/// same AND their runtime types are the same.
	///
	/// This means that a `None<int>()` is not equal to `None<String>()` even though
	/// they are both `None()`.
	@override
	operator ==(Object other) => switch (other) {
		Some(value: T value) when isSome() && compareRuntimeTypes(this, other) => value == unwrap(),
		None() when isNone() && compareRuntimeTypes(this, other) => true,
		_ => false
	};

	/// Shortcut to call [Option.unwrap()].
	///
	/// **Warning**: This is an *unsafe* operation. An [OptionError] will be thrown
	/// if this operator is used on a [None] value. You can take advantage of this
	/// safely via [propagateOption]/[propagateOptionAsync] and their respective
	/// shortcuts ([OptionPropagateShortcut.~]/[OptionPropagateShortcutAsync.~]).
	///
	/// This is as close to analagous to Rust's `?` postfix operator for `Option`
	/// values as Dart can manage. There are no overrideable postfix operators in
	/// Dart, sadly, so this won't be as ergonomic as Rust but it's still nicer
	/// than calling [Option.unwrap()].
	///
	/// ```dart
	/// var foo = Some(1);
	/// var bar = Some(2);
	///
	/// print(~foo + ~bar); // prints: 3
	/// ```
	///
	/// **Note**: if you need to access fields or methods on the held value when
	/// using `~`, you'll need to use parentheses like so:
	///
	/// ```dart
	/// var opt = Some(1);
	///
	/// print((~opt).toString());
	/// ```
	///
	/// Additionally, If you need to perform a bitwise NOT on the held value of
	/// an `Option`, you have a few choices:
	///
	/// ```dart
	/// var opt = Some(1);
	///
	/// print(~(~opt)); // prints: -2
	/// print(~~opt); // prints: -2
	/// print(~opt.unwrap()); // prints: -2;
	/// ```
	T operator ~() => unwrap();

	/// Returns whether or not this `Option` holds a value ([Some]).
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
	bool isSomeAnd(bool Function(T) predicate) => switch (this) {
		Some(value: T value) => predicate(value),
		None() => false
	};

	/// Returns whether or not this `Option` holds no value ([None]).
	bool isNone() => !isSome();

	/// Returns the held value of this `Option` if it is [Some].
	///
	/// **Warning**: This method is *unsafe*. An [OptionError] will be thrown when
	/// this method is called if this `Option` is [None].
	T unwrap() => switch (this) {
		Some(value: T value) => value,
		None() => throw OptionError('called `Option#unwrap()` on a `None` value')
	};

	/// Returns the held value of this `Option` if it is [Some], or the given value
	/// if this `Option` is [None].
	T unwrapOr(T orValue) => switch (this) {
		Some(value: T value) => value,
		None() => orValue
	};

	/// Returns the held value of this `Option` if it is [Some], or returns the
	/// returned value from `elseFn` if this `Option` is [None].
	T unwrapOrElse(T Function() elseFn) => switch (this) {
		Some(value: T value) => value,
		None() => elseFn()
	};

	/// Returns the held value of this `Option` if it is [Some], or throws [OptionError]
	/// with the given `message` if this `Option` is [None].
	T expect(String message) => switch (this) {
		Some(value: T value) => value,
		None() => throw OptionError(message, isExpected: true)
	};

	/// Returns [None<U>] if this `Option` is [None<T>], otherwise returns `other`.
	Option<U> and<U>(Option<U> other) => switch (this) {
		Some() => other,
		None() => None()
	};

	/// Returns [None<U>] if this `Option` is [None<T>], otherwise calls `fn` with
	/// the held value and returns the returned `Option`.
	Option<U> andThen<U>(Option<U> Function(T) fn) => switch (this) {
		Some(value: T value) => fn(value),
		None() => None()
	};

	/// Returns this `Option` if this `Option` is [Some<T>], otherwise returns `other`.
	Option<T> or(Option<T> other) => switch (this) {
		Some() => this,
		None() => other
	};

	/// Returns this `Option` if this `Option` is [Some<T>], otherwise calls `fn`
	/// and returns the returned `Option`.
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
	Option<T> inspect(void Function(T) fn) {
		if (this case Some(value: T v)) {
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
	Option<T> filter(bool Function(T) predicate) => switch (this) {
		Some(value: T value) => predicate(value) ? this : None(),
		None() => this
	};

	/// Maps this `Option<T>` to an `Option<U>` using the given function with the
	/// held value.
	///
	/// Returns:
	/// - [Some<U>] if this `Option` is [Some<T>].
	/// - [None<U>] if this `Option` is [None].
	Option<U> map<U>(U Function(T) mapFn) => switch (this) {
		Some(value: T value) => Some(mapFn(value)),
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
	/// [Option.map_or()](https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or),
	/// this method returns an `Option` value. Given that [Option.map()] returns
	/// the mapped `Option` it just made sense for this method to do the same.
	Option<U> mapOr<U>(U orValue, U Function(T) mapFn) => switch (this) {
		Some(value: T value) => Some(mapFn(value)),
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
	/// [Option.map_or_else()](https://doc.rust-lang.org/std/option/enum.Option.html#method.map_or_else),
	/// this method returns an `Option` value. Given that [Option.map()] returns
	/// the mapped `Option` it just made sense for this method to do the same.
	Option<U> mapOrElse<U>(U Function() orFn, U Function(T) mapFn) => switch (this) {
		Some(value: T value) => Some(mapFn(value)),
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
	Option<(T, U)> zip<U>(Option<U> other) => switch ((this, other)) {
		(Some(value: T a), Some(value: U b)) => Some((a, b)),
		_ => None()
	};

	/// Zips this `Option` with another `Option` using the given function.
	///
	/// Returns:
	/// - [Some<V>] if this `Option` is [Some<T>] and `other` is [Some<U>].
	/// - [None<V>] otherwise.
	Option<V> zipWith<U, V>(Option<U> other, V Function(T, U) zipFn) => switch ((this, other)) {
		(Some(value: T a), Some(value: U b)) => Some(zipFn(a, b)),
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
	Result<T, E> okOr<E>(E err) => switch (this) {
		Some(value: T value) => Ok(value),
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
	Result<T, E> okOrElse<E>(E Function() elseFn) => switch (this) {
		Some(value: T value) => Ok(value),
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

	Some(this.value);
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
class None<T> extends Option<T> {}

/// Provides the `unzip()` method to [Option] type values that hold a [Record] of two values.
extension OptionUnzip<T, U> on Option<(T, U)> {
	/// Unzips this `Option` if this `Option` holds a [Record] of two values.
	///
	/// Returns:
	/// - `(Some<U>, Some<V>)` if this `Option` is [Some<(U, V)>].
	/// - `(None<U>, None<V>)` if this `Option` is [None<(U, V)>].
	(Option<T>, Option<U>) unzip() => switch (this) {
		Some(value: (T a, U b)) => (Some(a), Some(b)),
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
	Option<T> flatten() => switch (this) {
		Some(value: Option<T> value) => value,
		None() => None()
	};
}

/// Provides the `transpose()` method to [Option] type values that hold a [Result].
extension OptionTranspose<T, E> on Option<Result<T, E>> {
	/// Transposes this [Option<Result<T, E>>] into a [Result<Option<T>, E>].
	///
	/// Returns:
	/// - [Ok<Some<T>, E>] if this `Option` is [Some<Ok<T, E>>].
	/// - [Err<T, E>] if this `Option` is [Some<Err<T, E>>].
	/// - [Ok<None<T>, E>] if this `Option` is [None<Result<T, E>>].
	Result<Option<T>, E> transpose() => switch (this) {
		Some(value: Ok(value: T value)) => Ok(Some(value)),
		Some(value: Err(value: E value)) => Err(value),
		None() => Ok(None())
	};
}
