part of option;

//TODO: Improve code examples for propagateResult/Option to show both outcome variants (Ok/Err and Some/None)

/// Executes the given function, returning the returned [Option] value.
///
/// If an [OptionError] is thrown during the execution of the given function,
/// which occurs when a [None] value is unwrapped, [None] will be returned.
///
/// This effectively allows safely unwrapping [Option] values within the given function,
/// propagating [None] to the returned value in the same way that the `?` operator
/// does in Rust. The simplest way to do this is to wrap your function body inside
/// this function like so:
///
/// ```dart
/// Option<int> add(Option<int> a, Option<int> b) => propagateOption(() {
///   // The equivalent non-idiomatic Rust return here would be:
///   // return Some(a? + b?);
///   return Some(a.unwrap() + b.unwrap());
///
///   // You can also use the ~ operator as a shortcut for unwrap():
///   // return Some(~a + ~b);
/// });
///
/// Option<int> foo = Some(1);
/// Option<int> bar = None();
/// Option<int> baz = add(foo, bar);
///
/// // Prints 'There is no value!' due to the OptionError thrown
/// // when unwrapping the None value contained in `bar`
/// print(switch (baz) {
///   Some(value: int value) => 'Value is $value',
///   None() => 'There is no value!'
/// });
/// ```
///
/// Note that any other type of thrown error/exception other than [OptionError] will be rethrown.
///
/// See also: [OptionPropagateShortcut.~]
Option<T> propagateOption<T>(Option<T> Function() fn) {
	try { return fn(); }
	catch (error) { return _handleOptionError(error); }
}

/// Executes the given function asynchronously, returning the returned [Option] value.
///
/// If an [OptionError] is thrown during the execution of the given function,
/// which occurs when a [None] value is unwrapped, [None] will be returned.
///
/// Behaves identically to [propagateOption] but async, returning `Future<Option<T>>`
/// rather than `Option<T>`.
///
/// See also: [OptionPropagateShortcutAsync.~]
Future<Option<T>> propagateOptionAsync<T>(FutureOr<Option<T>> Function() fn) async {
	try { return await fn(); }
	catch (error) { return _handleOptionError(error); }
}

/// Propagate `None()` on `OptionError` unless the error came from `expect()`.
Option<T> _handleOptionError<T>(dynamic error) {
	if (error is OptionError) {
		// If the error is expected (came from expect()), rethrow it
		if (error.isExpected) {
			throw error;
		}

		// Otherwise return None()
		return None();
	}

	throw error;
}

/// Provides the `~` shortcut for functions that return [Option] to allow propagating
/// unwrapped [None] values up the call stack.
///
/// See: [OptionPropagateShortcut.~]
extension OptionPropagateShortcut<T> on Option<T> Function() {
	/// Shortcut for [propagateOption].
	///
	/// Usage:
	///
	/// ```dart
	/// // This function will error at runtime if passed a None() value
	/// Option<int> add(Option<int> a, Option<int> b) {
	///   return Some(a.unwrap() + b.unwrap());
	/// }
	///
	/// // For safety, it can be rewritten as:
	/// Option<int> add(Option<int> a, Option<int> b) => ~() {
	///   return Some(a.unwrap() + b.unwrap());
	///
	///   // You can also use the ~ operator as a shortcut for unwrap():
	///   // return Some(~a + ~b);
	/// };
	///
	/// // Runtime safety achieved from a mere 8 total characters of syntactical overhead!
	/// ```
	Option<T> operator ~() => propagateOption(this);
}

/// Provides the `~` shortcut for asynchronous functions that return [Option] to
/// allow propagating unwrapped [None] values up the call stack.
///
/// See: [OptionPropagateShortcutAsync.~]
extension OptionPropagateShortcutAsync<T> on Future<Option<T>> Function() {
	/// Shortcut for [propagateOptionAsync].
	///
	/// Usage:
	///
	/// ```dart
	/// // This function will error at runtime if passed a None() value
	/// Future<Option<int>> add(Option<int> a, Option<int> b) async {
	///   return Some(a.unwrap() + b.unwrap());
	/// }
	///
	/// // For safety, it can be rewritten as:
	/// Future<Option<int>> add(Option<int> a, Option<int> b) => ~() async {
	///   return Some(a.unwrap() + b.unwrap());
	///
	///   // You can also use the ~ operator as a shortcut for unwrap():
	///   // return Some(~a + ~b);
	/// };
	///
	/// // Runtime safety achieved from a mere 8 total characters of syntactical overhead!
	/// ```
	Future<Option<T>> operator ~() => propagateOptionAsync(this);
}
