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
/// Option<int> foo = Some(1);
/// Option<int> bar = None();
///
/// Option<int> add(Option<int> a, Option<int> b) => propagateOption(() {
///   // The equivalent non-idiomatic Rust return here would be:
///   // return Some(a? + b?);
///   return Some(a.unwrap() + b.unwrap());
/// });
///
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
Option<T> propagateOption<T>(Option<T> Function() fn) {
	try { return fn(); }
	on OptionError { return None(); }
	catch (_) { rethrow; }
}

/// Executes the given function asynchronously, returning the returned [Option] value.
///
/// If an [OptionError] is thrown during the execution of the given function,
/// which occurs when a [None] value is unwrapped, [None] will be returned.
///
/// Behaves identically to [propagateOption] but async, returning `Future<Option<T>>`
/// rather than `Option<T>`.
Future<Option<T>> propagateOptionAsync<T>(FutureOr<Option<T>> Function() fn) async {
	try { return await fn(); }
	on OptionError { return None(); }
	catch (_) { rethrow; }
}
