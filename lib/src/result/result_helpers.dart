part of result;

//TODO: Improve code examples for propagateResult/Option to show both outcome variants (Ok/Err and Some/None)

/// Executes the given function, returning the returned [Result] value.
///
/// If a [ResultError] is thrown during the execution of the given function,
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
/// // Prints 'Error: There was an error!!' due to the ResultError
/// // thrown when unwrapping the Err value contained in `bar`
/// print(switch (baz) {
///   Ok(value: int value) => 'Value is $value',
///   Err(value: String err) => 'Error: $err'
/// });
/// ```
///
/// Note that any other type of thrown error/exception other than [OptionError] will be rethrown.
Result<T, E> propagateResult<T, E>(Result<T, E> Function() fn) {
	try { return fn(); }
	catch (err) { return _handleResultError(err); }
}

/// Executes the given function asynchronously, returning the returned [Result] value.
///
/// If a [ResultError] is thrown during the execution of the given function, which
/// occurs when an [Err] value is unwrapped, the [Err] that was unwrapped will be returned.
///
/// Behaves identically to [propagateResult] but async, returning `Furture<Result<T, E>>`
/// rather than `Result<T, E>`.
Future<Result<T, E>> propagateResultAsync<T, E>(FutureOr<Result<T, E>> Function() fn) async {
	try { return await fn(); }
	catch (err) { return _handleResultError(err); }
}

/// Attempt to propagate the given error if it is a ResultError, otherwise rethrow
Result<T, E> _handleResultError<T, E>(dynamic err) {
	try { throw err; }

	// Propagate the original Err() if it's provided, otherwise create a new one
	// from the caught error message
	on ResultError<T, E> catch (e) {
		// If the error came from unwrapErr() on an Ok() result, rethrow
		if (e.original case Ok()) {
			rethrow;
		}

		return e.original ?? Err(e.message);
	}

	// If the caught ResultError doesn't match the expected ResultError type, throw a new ResultError
	on ResultError catch (_) {
		throw ResultError('attempted to propagate an Err() that does not match the expected return type');
	}

	// Rethrow anything else
	catch (_) { rethrow; }
}
