part of result;

//TODO: Improve code examples for propagateResult/Option to show both outcome variants (Ok/Err and Some/None)

/// Executes the given function, returning the returned [Result] value.
///
/// If a [ResultError] is thrown during the execution of the given function,
/// which occurs when an [Err()] value is unwrapped, the [Err()] that was unwrapped
/// will be returned.
///
/// This effectively allows safely unwrapping [Result] values within the given function,
/// propagating [Err()] to the returned value in the same way that the `?` operator
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
/// Note that any other type of thrown error/exception other than [ResultError]
/// will be rethrown. Additionally, The propagated [Err()] type will be repackaged
/// to match the `T` of the expected return type of this function, and if the `E`
/// value type of the propagated [Err()] does not match the expected `E` value type
/// of this function, a [ResultError] will be thrown.
Result<T, E> propagateResult<T, E>(Result<T, E> Function() fn) {
	try { return fn(); }
	catch (error) { return _handleResultError(error); }
}

/// Executes the given function asynchronously, returning the returned [Result] value.
///
/// If a [ResultError] is thrown during the execution of the given function, which
/// occurs when an [Err()] value is unwrapped, the [Err()] that was unwrapped will be returned.
///
/// Behaves identically to [propagateResult] but async, returning `Furture<Result<T, E>>`
/// rather than `Result<T, E>`.
Future<Result<T, E>> propagateResultAsync<T, E>(FutureOr<Result<T, E>> Function() fn) async {
	try { return await fn(); }
	catch (error) { return _handleResultError(error); }
}

/// Attempt to propagate the given error if it is a ResultError, otherwise rethrow
Result<T, E> _handleResultError<T, E>(dynamic error) {
	// Attempt to propagate original Err()
	if (error is ResultError) {
		// If the error came from unwrapErr() on an Ok() result, rethrow
		if (error.original case Ok()) {
			throw error;
		}

		// Rethrow if we don't have an original Err(). This shouldn't happen except
		// in the above case, but just as a precaution
		if (error.original == null) {
			throw error;
		}

		// Try to repackage the original Err() to match the expected return type
		try {
			return Err(error.original!.unwrapErr());
		}

		// Throw a ResultError if there's a TypeError returning the repackaged Err()
		on TypeError catch (e) {
			throw ResultError('Failed to repackage Err() as expected propagation type: ${e.toString()}');
		}

		// Rethrow anything else
		catch (_) { rethrow; }
	}

	// Rethrow any other kind of error
	throw error;
}
