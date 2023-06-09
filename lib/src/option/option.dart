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
	/// The `Option` class cannot be instantiated directly. use [Some], [None], or
	/// [Option.from] to create instances of `Option` variants
	Option();

	/// Creates an `Option` from the given nullable `T` value.
	///
	/// Creates:
	/// - [Some] if the given value is not null
	/// - [None] if the given value is null
	factory Option.from(T? value) => switch (value) {
		null => None(),
		_ => Some(value)
	};

	/// Compare equality between two `Option` values.
	///
	/// `Option` values are considered equal only if the value they hold is the
	/// same AND their runtime types are the same.
	///
	/// This means that a `None<int>()` is not equal to `None<String>()` even though
	/// they are both `None()`
	@override
	operator ==(Object other) => switch (other) {
		Some(value: T value) when isSome() && compareRuntimeTypes(this, other) => value == unwrap(),
		None() when isNone() && compareRuntimeTypes(this, other) => true,
		_ => false
	};

	@override
	int get hashCode => switch (this) {
		Some(value: T value) => value.hashCode,
		None() => Object.hash('None()', runtimeType)
	};

	/// Returns whether or not this `Option` holds a value ([Some])
	bool isSome() => switch (this) {
		Some() => true,
		None() => false
	};

	/// Returns whether or not this `Option` holds no value ([None])
	bool isNone() => !isSome();

	/// Returns the held [Some] value.
	///
	/// Throws an [OptionError] if this `Option` is a [None] value
	T unwrap() => switch (this) {
		Some(value: T value) => value,
		None() => throw OptionError('called `Option#unwrap()` on a `None` value')
	};

	/// Returns the held [Some] value, or the given value if this `Option` is a [None] value
	T unwrapOr(T orValue) => switch (this) {
		Some(value: T value) => value,
		None() => orValue
	};

	/// Filters this `Option` based on the given `predicate` function.
	///
	/// Returns [None] if this `Option` is [None], otherwise calls `predicate` with
	/// the held value, returning:
	///
	/// - `Some(value)` if `predicate` returns true (where `value` is the held value).
	/// - `None()` if `predicate` returns `false`.
	Option<T> filter(bool Function(T) predicate) => switch (this) {
		None() => this,
		Some(value: T value) => predicate(value) ? this : None()
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
