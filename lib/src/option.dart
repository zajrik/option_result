import 'package:equatable/equatable.dart';

/// `Option` is a type that represents the presence ([Some]) or absence ([None]) of a value.
///
/// Pattern matching is recommended for working with `Option` types.
///
/// ```dart
/// Option<int> foo = Some(42);
///
/// print(switch (foo) {
///   Some(value: bar) => 'Some value: $bar',
///   None() => 'No value!'
/// });
/// ```
sealed class Option<T> extends Equatable {
	/// Returns whether or not this `Option` holds a value ([Some])
	bool isSome() => switch (this) {
		Some() => true,
		None() => false
	};

	/// Returns whether or not this `Option` holds no value ([None])
	bool isNone() => !isSome();

	/// Returns the contained [Some] value. Throws an [OptionException] if this `Option` is a [None] value
	T unwrap() => switch (this) {
		Some(value: T value) => value,
		None() => throw OptionException('called `Option#unwrap()` on a `None` value')
	};

	/// Returns the contained [Some] value, or the given value if this `Option` is a [None] value
	T unwrapOr(T orValue) => switch (this) {
		Some(value: T value) => value,
		None() => orValue
	};
}

/// Represents and holds some value of type `T`.
///
/// Pattern matching is recommended for working with [Option] types.
///
/// ```dart
/// Option<int> foo = Some(42);
///
/// if (foo case Some(value: bar)) {
///   print(bar);
/// }
/// ```
class Some<T> extends Option<T> {
	final T value;

	Some(this.value);

	@override
	List<T> get props => [value];
}

/// Represents the absence of a value.
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
	@override
	List<T> get props => [];
}

/// Represents an exception thrown by an [Option] type value
class OptionException implements Exception {
	final dynamic message;

	OptionException([this.message]);

	@override
	String toString() => switch (message) {
		null => 'OptionException',
		_ => 'OptionException: $message'
	};
}
