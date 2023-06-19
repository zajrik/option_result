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
/// Result<int, String> add(Result<int, String> a, Result<int, String> b) => propagateResult(() {
///   // The equivalent non-idiomatic Rust return here would be:
///   // return Ok(a? + b?);
///   return Ok(a.unwrap() + b.unwrap());
///
///   // You can also use the ~ operator as a shortcut for unwrap():
///   // return Ok(~a + ~b);
/// });
///
/// Result<int, String> foo = Ok(1);
/// Result<int, String> bar = Err('There was an error!');
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
///
/// See also: [ResultPropagateShortcut.~]
Result<T, E> propagateResult<T, E>(Result<T, E> Function() fn) {
	try { return fn(); }
	catch (error) { return _handleResultError(error); }
}

/// Executes the given function asynchronously, returning the returned [Result] value.
///
/// If a [ResultError] is thrown during the execution of the given function, which
/// occurs when an [Err()] value is unwrapped, the [Err()] that was unwrapped will be returned.
///
/// Behaves identically to [propagateResult] but async, returning `Future<Result<T, E>>`
/// rather than `Result<T, E>`.
///
/// See also: [ResultPropagateShortcutAsync.~]
Future<Result<T, E>> propagateResultAsync<T, E>(FutureOr<Result<T, E>> Function() fn) async {
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
		// have an original Err(). The latter should never happen except in the above
		// case but just as a precaution we'll check for it
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

/// Provides the `~` shortcut for functions that return [Result] to allow propagating
/// unwrapped [Err] values up the call stack.
///
/// See: [ResultPropagateShortcut.~]
extension ResultPropagateShortcut<T, E> on Result<T, E> Function() {
	/// Executes the prefixed function, propagating any unwrapped [Err()] values
	/// to the return value of the function.
	///
	/// Shortcut for [propagateResult].
	///
	/// Usage:
	///
	/// ```dart
	/// // This function will error at runtime if passed an Err() value
	/// Result<int, String> add(Result<int, String> a, Result<int, String> b) {
	///   return Ok(a.unwrap() + b.unwrap());
	/// }
	///
	/// // For safety, it can be rewritten as:
	/// Result<int, String> add(Result<int, String> a, Result<int, String> b) => ~() {
	///   return Ok(a.unwrap() + b.unwrap());
	///
	///   // You can also use the ~ operator as a shortcut for unwrap():
	///   // return Ok(~a + ~b);
	/// };
	///
	/// // Runtime safety achieved from a mere 8 total characters of syntactical overhead!
	/// ```
	///
	/// **Note:** You will want to explicitly type receivers of this operation due
	/// to how the compiler handles generic return values from operators vs functions.
	///
	/// When this operator is typed to return [Result<T, E>] and you return [Ok()]
	/// or [Err()] in the prefixed function, the compiler treats the prefixed function
	/// as returning [Result<T, dynamic>] or [Result<dynamic, E>] which is fine when
	/// using [propagateResult] because it is able to gather type information from
	/// the return value of the given function, as well as from the receiver, but
	/// the operator cannot so it just errors at compile time. Example:
	///
	/// ```dart
	/// // Compiles fine
	/// Result<int, String> foo = propagateResult(() => Ok(1));
	///
	/// // Error: A value of type 'Result<int, dynamic>' can't be assigned to a variable of type 'Result<int, String>'
	/// Result<int, String> bar = ~() => Ok(1);
	///
	/// // The only way around this would be to explicitly specify the type parameters
	/// // on the returned result like:
	/// Result<int, String> baz = ~() => Ok<int, String>(1);
	///
	/// // And that's not very ergonomic when you are already likely to type your
	/// // variables and function/method returns
	/// ```
	///
	/// Hence, this operator returns `dynamic`. If this is undesireable for you,
	/// consider using [propagateResult] directly instead.
	operator ~() => propagateResult(this);
}

/// Provides the `~` shortcut for asynchronous functions that return [Result] to
/// allow propagating unwrapped [Err] values up the call stack.
///
/// See: [ResultPropagateShortcutAsync.~]
extension ResultPropagateShortcutAsync<T, E> on Future<Result<T, E>> Function() {
	/// Shortcut for [propagateResultAsync].
	///
	/// Usage:
	///
	/// ```dart
	/// // This function will error at runtime if passed an Err() value
	/// Future<Result<int, String>> add(Result<int, String> a, Result<int, String> b) async {
	///   return Ok(a.unwrap() + b.unwrap());
	/// }
	///
	/// // For safety, it can be rewritten as:
	/// Future<Result<int, String>> add(Result<int, String> a, Result<int, String> b) => ~() async {
	///   return Ok(a.unwrap() + b.unwrap());
	///
	///   // You can also use the ~ operator as a shortcut for unwrap():
	///   // return Ok(~a + ~b);
	/// };
	///
	/// // Runtime safety achieved from a mere 8 total characters of syntactical overhead!
	/// ```
	///
	/// **Note:** You will want to explicitly type receivers of this operation due
	/// to how the compiler handles generic return values from operators vs functions.
	///
	/// When this operator is typed to return [Future<Result<T, E>>] and you return
	/// [Ok()] or [Err()] in the prefixed function, the compiler treats the prefixed
	/// function as returning [Future<Result<T, dynamic>>] or [Future<Result<dynamic, E>>]
	/// which is fine when using [propagateResultAsync] because it is able to gather
	/// type information from the return value of the given function, as well as from
	/// the receiver, but the operator cannot so it just errors at compile time. Example:
	///
	/// ```dart
	/// // Compiles fine
	/// Result<int, String> foo = await propagateResultAsync(() async => Ok(1));
	///
	/// // Error: A value of type 'Result<int, dynamic>' can't be assigned to a variable of type 'Result<int, String>'
	/// Result<int, String> bar = await ~() async => Ok(1);
	///
	/// // The only way around this would be to explicitly specify the type parameters
	/// // on the returned result like:
	/// Result<int, String> baz = await ~() async => Ok<int, String>(1);
	///
	/// // And that's not very ergonomic when you are already likely to type your
	/// // variables and function/method returns
	/// ```
	///
	/// Hence, this operator returns `dynamic`. If this is undesireable for you,
	/// consider using [propagateResultAsync] directly instead.
	operator ~() => propagateResultAsync(this);
}
