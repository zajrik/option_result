import 'dart:async';

import '../result_option.dart';

//TODO: Improve code examples for propagateResult/Option to show both outcome variants (Ok/Err and Some/None)

/// Executes the given function, returning the returned [Result] value.
///
/// If a [ResultException] is thrown during the execution of the given function,
/// which occurs when an [Err] value is unwrapped, the [Err] that was unwrapped
/// will be returned.
///
/// This effectively allows safely unwrapping [Result] values within the given function,
/// propagating [Err] to the returned value in the same way that the `?` operator
/// does in Rust. The simplest way to do this is to wrap your function body inside
/// this function like so:
///
/// ```dart
/// Result<int, String> foo = Ok(1);
/// Result<int, String> bar = Err('There was an error!');
///
/// Result<int, String> add(Result<int, String> a, Result<int, String> b) => propagateResult(() {
///   // The equivalent non-idiomatic Rust return here would be:
///   // return Some(a? + b?);
///   return Ok(a.unwrap() + b.unwrap());
/// });
///
/// Result<int, String> baz = add(foo, bar);
///
/// // Prints 'Error: There was an error!!' due to the ResultException
/// // thrown when unwrapping the Err value contained in `bar`
/// print(switch (baz) {
///   Ok(value: int value) => 'Value is $value',
///   Err(value: String err) => 'Error: $err'
/// });
/// ```
///
/// Note that any other type of thrown exception other than [OptionException] will be rethrown.
Result<T, E> propagateResult<T, E>(Result<T, E> Function() fn) {
	try { return fn(); }
	on ResultException catch (e) { return Err(e.message); }
	catch (_) { rethrow; }
}

/// Executes the given function, returning the returned [Result] value.
///
/// If a [ResultException] is thrown during the execution of the given function, which
/// occurs when an [Err] value is unwrapped, the [Err] that was unwrapped will be returned.
///
/// Behaves identically to [propagateResult] but async, returning `Furture<Result<T, E>>`
/// rather than `Result<T, E>`.
Future<Result<T, E>> propagateResultAsync<T, E>(FutureOr<Result<T, E>> Function() fn) async {
	try { return await fn(); }
	on ResultException catch (e) { return Err(e.message); }
	catch (_) { rethrow; }
}

/// Executes the given function, returning the returned [Option] value.
///
/// If an [OptionException] is thrown during the execution of the given function,
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
/// // Prints 'There is no value!' due to the OptionException thrown
/// // when unwrapping the None value contained in `bar`
/// print(switch (baz) {
///   Some(value: int value) => 'Value is $value',
///   None() => 'There is no value!'
/// });
/// ```
///
/// Note that any other type of thrown exception other than [OptionException] will be rethrown.
Option<T> propagateOption<T>(Option<T> Function() fn) {
	try { return fn(); }
	on OptionException { return None(); }
	catch (_) { rethrow; }
}

/// Executes the given function, returning the returned [Option] value.
///
/// If an [OptionException] is thrown during the execution of the given function,
/// which occurs when a [None] value is unwrapped, [None] will be returned.
///
/// Behaves identically to [propagateOption] but async, returning `Furture<Option<T>>`
/// rather than `Option<T>`.
Future<Option<T>> propagateOptionAsync<T>(FutureOr<Option<T>> Function() fn) async {
	try { return await fn(); }
	on OptionException { return None(); }
	catch (_) { rethrow; }
}
