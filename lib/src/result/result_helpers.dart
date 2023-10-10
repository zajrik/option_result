part of result;

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
/// // The equivalent (non-idiomatic) Rust return in divideByTwo() would be:
/// // return Ok(value? / 2);
///
/// Result<int, String> divideByTwo(Result<int, String> value) => catchResult(() {
///   return Ok(value.unwrap() ~/ 2);
/// });
///
/// Result<int, String> foo = Ok(42);
/// Result<int, String> bar = Err('There was an error!');
///
/// Result<int, String> result1 = divideByTwo(foo); // Ok(21)
/// Result<int, String> result2 = divideByTwo(bar); // Err('There was an error!')
/// ```
///
/// Note that any other type of thrown error/exception other than [ResultError]
/// will be rethrown. Additionally, The propagated [Err()] type will be repackaged
/// to match the `T` of the expected return type of this function, and if the `E`
/// value type of the propagated [Err()] does not match the expected `E` value type
/// of this function, a [ResultError] will be thrown.
///
/// See also: [Result.call()]
Result<T, E> catchResult<T, E>(Result<T, E> Function() fn) {
	try { return fn(); }
	catch (error) { return _handleResultError(error); }
}

/// Executes the given function asynchronously, returning the returned [Result] value.
///
/// If a [ResultError] is thrown during the execution of the given function, which
/// occurs when an [Err()] value is unwrapped, the [Err()] that was unwrapped will be returned.
///
/// Behaves identically to [catchResult] but async, returning `Future<Result<T, E>>`
/// rather than `Result<T, E>`.
///
/// See also: [Result.call()]
Future<Result<T, E>> catchResultAsync<T, E>(FutureOr<Result<T, E>> Function() fn) async {
	try { return await fn(); }
	catch (error) { return _handleResultError(error); }
}

/// Attempt to propagate the given error if it is a ResultError, otherwise rethrow.
Result<T, E> _handleResultError<T, E>(dynamic error) {
	// Attempt to propagate original Err()
	if (error is ResultError) {
		// If the error came from unwrapErr() on an Ok() result, rethrow
		if (error.original case Ok()) {
			throw error;
		}

		// Rethrow if this error is from Result#expect()/expectErr(), or if we don't
		// have an original Err() (should only happen from unwrapErr on Ok or from
		// expect/expectErr)
		if (error.isExpected || error.original == null) {
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

/// Represents a [Future] that completes with a [Result] of the given types `T`, `E`.
///
/// This is simply a convenience typedef to save a couple characters.
typedef FutureResult<T, E> = Future<Result<T, E>>;

/// Represents a [FutureOr] that is or completes with a [Result] of the given types `T`, `E`.
///
/// This is simply a convenience typedef to save a couple characters.
typedef FutureOrResult<T, E> = FutureOr<Result<T, E>>;
