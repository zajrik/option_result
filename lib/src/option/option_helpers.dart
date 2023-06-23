part of option;

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
/// // The equivalent (non-idiomatic) Rust return in divideByTwo() would be:
/// // return Some(value? / 2);
///
/// Option<int> divideByTwo(Option<int> value) => propagateOption(() {
///   return Some(value.unwrap() ~/ 2);
/// });
///
/// Option<int> foo = Some(42);
/// Option<int> bar = None();
///
/// Option<int> result1 = divideByTwo(foo); // Some(21)
/// Option<int> result2 = divideByTwo(bar); // None()
/// ```
///
/// Note that any other type of thrown error/exception other than [OptionError] will be rethrown.
///
/// See also: [Option.~], [OptionPropagateShortcut.~]
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
	/// Executes the prefixed function, propagating any unwrapped [None()] values
	/// to the return value of the function.
	///
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
	/// Executes the prefixed async function, propagating any unwrapped [None()]
	/// values to the return value of the function.
	///
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
