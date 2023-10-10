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
/// Option<int> divideByTwo(Option<int> value) => catchOption(() {
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
/// See also: [Option.call()]
Option<T> catchOption<T>(Option<T> Function() fn) {
	try { return fn(); }
	catch (error) { return _handleOptionError(error); }
}

/// Executes the given function asynchronously, returning the returned [Option] value.
///
/// If an [OptionError] is thrown during the execution of the given function,
/// which occurs when a [None] value is unwrapped, [None] will be returned.
///
/// Behaves identically to [catchOption] but async, returning `Future<Option<T>>`
/// rather than `Option<T>`.
///
/// See also: [Option.call()]
Future<Option<T>> catchOptionAsync<T>(FutureOr<Option<T>> Function() fn) async {
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

/// Represents a [Future] that completes with an [Option] of the given type `T`.
///
/// This is simply a convenience typedef to save a couple characters.
typedef FutureOption<T> = Future<Option<T>>;

/// Represents a [FutureOr] that is or completes with an [Option] of the given type `T`.
///
/// This is simply a convenience typedef to save a couple characters.
typedef FutureOrOption<T> = FutureOr<Option<T>>;
