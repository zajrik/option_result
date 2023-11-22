part of result;

/// A type that represents the result of something, either success ([Ok]) or failure ([Err]).
///
/// A `Result` type holds either a value of type `T`, or an error value of type `E`.
///
/// Pattern matching is recommended for interacting with `Result` types.
///
/// ```dart
/// Result<int, String> foo = Ok(42);
///
/// print(switch (foo) {
///   Ok(v: var bar) => 'Ok value: $bar',
///   Err(e: var err) => 'Error value: $err',
/// });
/// ```
///
/// See also:
/// [Rust: `Result`](https://doc.rust-lang.org/std/result/enum.Result.html)
sealed class Result<T extends Object, E extends Object> {
  /// The `Result` class cannot be instantiated directly. use [Ok()], [Err()],
  /// or [Result.from()] to create instances of `Result` variants.
  const Result();

  /// Creates a `Result` from the given nullable `T` value.
  ///
  /// Creates:
  /// - [Ok] using the given `T` value if the given `T` value is not null.
  /// - [Err] using the given `E` value if the given `T` value is null.
  factory Result.from(T? value, E error) => switch (value) {
        null => Err(error),
        _ => Ok(value),
      };

  @override
  int get hashCode => switch (this) {
        Ok(:T v) => Object.hash('Ok()', v),
        Err(:E e) => Object.hash('Err()', e),
      };

  /// Compare equality between two `Result` values.
  ///
  /// `Result` values are considered equal if the values they hold are equal,
  /// or if they hold references to the same object ([identical()]). When comparing
  /// [Ok] values, the type of `E` will be elided, and `T` will be elided when
  /// comparing [Err] values.
  ///
  /// This means that [Ok<int, String>(1)] is equal to [Ok<int, int>(1)] and
  /// [Err<int, String>('foo')] is equal to [Err<bool, String>('foo')] because
  /// their held values are equatable and their irrelevant types are elided.
  @override
  operator ==(Object other) => switch (other) {
        Ok(:T v) when isOk() => identical(v, unwrap()) || v == unwrap(),
        Err(:E e) when isErr() => identical(e, unwrapErr()) || e == unwrapErr(),
        _ => false,
      };

  @override
  String toString() => switch (this) {
        Ok(:T v) => 'Ok($v)',
        Err(:E e) => 'Err($e)',
      };

  /// Shortcut to call [Result.unwrap()].
  ///
  /// Allows calling a `Result` value like a function as a shortcut to unwrap the
  /// held value of the `Result`.
  ///
  /// **Warning**: This is an *unsafe* operation. A [ResultError] will be thrown
  /// if this operation is used on an [Err] value. You can take advantage of this
  /// safely via [catchResult]/[catchResultAsync].
  ///
  /// ```dart
  /// var foo = Ok(1);
  /// var bar = Ok(2);
  ///
  /// print(foo() + bar()); // prints: 3
  /// ```
  ///
  /// See also:
  /// [Rust: `Result::unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap)
  T call() => unwrap();

  /// Returns whether or not this `Result` is [Ok].
  ///
  /// See also:
  /// [Rust: `Result::is_ok()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_ok)
  bool isOk() => switch (this) {
        Ok() => true,
        Err() => false,
      };

  /// Returns whether or not this `Result` is [Ok] and that the held value matches
  /// the given predicate.
  ///
  /// Returns:
  /// - `true` if this `Result` is [Ok] and `predicate` returns `true`.
  /// - `false` if this `Result` is [Err], or `predicate` returns `false`
  ///
  /// See also:
  /// [Rust: `Result::is_ok_and()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_ok_and)
  bool isOkAnd(bool Function(T v) predicate) => switch (this) {
        Ok(:T v) => predicate(v),
        Err() => false,
      };

  /// Returns whether or not this `Result` is [Err].
  ///
  /// See also:
  /// [Rust: `Result::is_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_err)
  bool isErr() => !isOk();

  /// Returns whether or not this `Result` is [Err] and that the held error value
  /// matches the given predicate.
  ///
  /// Returns:
  /// - `true` if this `Result` is [Err] and `predicate` returns `true`.
  /// - `false` if this `Result` is [Ok], or `predicate` returns `false`
  ///
  /// See also:
  /// [Rust: `Result::is_err_and()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.is_err_and)
  bool isErrAnd(bool Function(E e) predicate) => switch (this) {
        Ok() => false,
        Err(:E e) => predicate(e),
      };

  /// Returns the held value of this `Result` if it is [Ok].
  ///
  /// **Warning**: This method is *unsafe*. A [ResultError] will be thrown when
  /// this method is called if this `Result` is [Err].
  ///
  /// See also:
  /// [Rust: `Result::unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap)
  T unwrap() => switch (this) {
        Ok(:T v) => v,
        Err() => throw ResultError(
            'called `Result#unwrap()` on an `Err` value',
            original: this,
          )
      };

  /// Returns the held value of this `Result` if it is [Ok], or the given value
  /// if this `Result` is [Err].
  ///
  /// See also:
  /// [Rust: `Result::unwrap_or()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_or)
  T unwrapOr(T orValue) => switch (this) {
        Ok(:T v) => v,
        Err() => orValue,
      };

  /// Returns the held value of this `Result` if it is [Ok], or returns the
  /// returned value from `elseFn` if this `Result` is [Err].
  ///
  /// See also:
  /// [Rust: `Result::unwrap_or_else()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_or_else)
  T unwrapOrElse(T Function() elseFn) => switch (this) {
        Ok(:T v) => v,
        Err() => elseFn(),
      };

  /// Returns the held value of this `Result` if it is [Err].
  ///
  /// **Warning**: This method is *unsafe*. A [ResultError] will be thrown when
  /// this method is called if this `Result` is [Ok].
  ///
  /// See also:
  /// [Rust: `Result::unwrap_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap_err)
  E unwrapErr() => switch (this) {
        Ok(:T v) => throw ResultError(v),
        Err(:E e) => e,
      };

  /// Returns the held value of this `Result` if it is [Ok]. Throws a [ResultError]
  /// with the given `message` and held [Err] value if this `Result` is [Err].
  ///
  /// See also:
  /// [Rust: `Result::expect()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.expect)
  T expect(String message) => switch (this) {
        Ok(:T v) => v,
        Err(:E e) => throw ResultError(
            '$message: $e',
            isExpected: true,
          )
      };

  /// Returns the held value of this `Result` if it is [Err]. Throws a [ResultError]
  /// with the given `message` and held [Ok] value if this `Result` is [Ok].
  ///
  /// See also:
  /// [Rust: `Result::expect_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.expect_err)
  E expectErr(String message) => switch (this) {
        Ok(:T v) => throw ResultError(
            '$message: $v',
            isExpected: true,
          ),
        Err(:E e) => e
      };

  /// Returns an [Iterable] of the held value.
  ///
  /// Yields:
  /// - The held `T` value if [Ok].
  /// - Nothing if [Err].
  ///
  /// See also:
  /// [Rust: `Result::iter()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.iter)
  Iterable<T> iter() sync* {
    switch (this) {
      case Ok(:T v):
        yield v;
      case Err():
        return;
    }
  }

  /// Returns a `Result` value as [Err<U, E>] if this `Result` is [Err<T, E>],
  /// otherwise returns `other`.
  ///
  /// See also:
  /// [Rust: `Result::and()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.and)
  Result<U, E> and<U extends Object>(Result<U, E> other) => switch (this) {
        Ok() => other,
        Err(:E e) => Err(e),
      };

  /// Returns a `Result` value as [Err<U, E>] if this `Result` is [Err<T, E>],
  /// otherwise calls `fn` with the held [Ok] value and returns the returned `Result`.
  ///
  /// See also:
  /// [Rust: `Result::and_then()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.and_then)
  Result<U, E> andThen<U extends Object>(Result<U, E> Function(T v) fn) =>
      switch (this) {
        Ok(:T v) => fn(v),
        Err(:E e) => Err(e),
      };

  /// Returns a `Result` value as [Ok<T, F>] if this `Result` is [Ok<T, E>],
  /// otherwise returns `other`.
  ///
  /// See also:
  /// [Rust: `Result::or()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.or)
  Result<T, F> or<F extends Object>(Result<T, F> other) => switch (this) {
        Ok(:T v) => Ok(v),
        Err() => other,
      };

  /// Returns a `Result` value as [Ok<T, F>] if this `Result` is [Ok<T, E>],
  /// otherwise calls `fn` with the held [Err] value and returns the returned `Result`.
  ///
  /// See also:
  /// [Rust: `Result::or_else()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.or_else)
  Result<T, F> orElse<F extends Object>(Result<T, F> Function(E e) fn) =>
      switch (this) {
        Ok(:T v) => Ok(v),
        Err(:E e) => fn(e),
      };

  /// Calls the provided function with the contained value if this `Result` is [Ok].
  ///
  /// ```dart
  /// Result<int, String> foo = Ok(1);
  ///
  /// int bar = foo
  ///   .map((value) => value + 2)
  ///   .inspect((value) => print(value)) // prints: 3
  ///   .unwrap();
  ///
  /// print(bar); // prints: 3
  /// ```
  ///
  /// See also:
  /// [Rust: `Result::inspect()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.inspect)
  Result<T, E> inspect(void Function(T v) fn) {
    if (this case Ok(:T v)) {
      fn(v);
    }

    return this;
  }

  /// Calls the provided function with the contained error value if this `Result`
  /// is [Err].
  ///
  /// ```dart
  /// Result<int, String> foo = Err('foo');
  ///
  /// String bar = foo
  ///   .mapErr((value) => value + 'bar')
  ///   .inspectErr((value) => print(value)) // prints: foobar
  ///   .unwrapErr();
  ///
  /// print(bar); // prints: foobar
  /// ```
  ///
  /// See also:
  /// [Rust: `Result::inspect_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.inspect_err)
  Result<T, E> inspectErr(void Function(E e) fn) {
    if (this case Err(:E e)) {
      fn(e);
    }

    return this;
  }

  /// Maps a `Result<T, E>` to a `Result<U, E>` using the given function with the
  /// held value.
  ///
  /// Returns:
  /// - [Ok<U, E>] if this `Result` is [Ok<T, E>].
  /// - [Err<U, E>] if this `Result` is [Err<T, E>].
  ///
  /// See also:
  /// [Rust: `Result::map()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map)
  Result<U, E> map<U extends Object>(U Function(T v) mapFn) => switch (this) {
        Ok(:T v) => Ok(mapFn(v)),
        Err(:E e) => Err(e),
      };

  /// Maps a `Result<T, E>` to a `Result<U, E>` using the given function with the
  /// held value if the `Result<T, E>` is [Ok]. Otherwise returns the provided
  /// `orValue` as `Ok(orValue)`.
  ///
  /// Values passed for `orValue` are eagerly evaluated. Consider using [Result.mapOrElse()]
  /// to provide a default that will not be evaluated unless the `Result` is [Ok].
  ///
  /// ```dart
  /// Result<int, String> a = Ok(1);
  /// Result<int, String> b = Err('foo');
  ///
  /// print(a.mapOr(5, (val) => val + 1).unwrap()); // prints: 2
  /// print(b.mapOr(5, (val) => val + 1).unwrap()); // prints: 5
  /// ```
  ///
  /// **Note**: Unlike Rust's
  /// [Result.map_or()](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or),
  /// this method returns a `Result` value. Given that [Result.map()] returns
  /// the mapped `Result` it just made sense for this method to do the same.
  ///
  /// See also:
  /// [Rust: `Result::map_or()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or)
  Result<U, E> mapOr<U extends Object>(U orValue, U Function(T v) mapFn) =>
      switch (this) {
        Ok(:T v) => Ok(mapFn(v)),
        Err() => Ok(orValue),
      };

  /// Maps a `Result<T, E>` to a `Result<U, E>` using the given `mapFn` function with
  /// the held value if the `Result` is [Ok]. Otherwise returns the result of
  /// `orFn` as `Ok(orFn())`.
  ///
  /// `orFn` will only be evaluated if this `Result` is [Err].
  ///
  /// ```dart
  /// Result<int, String> a = Ok(1);
  /// Result<int, String> b = Err('foo');
  ///
  /// print(a.mapOrElse(() => 5, (val) => val + 1).unwrap()); // prints: 2
  /// print(b.mapOrElse(() => 5, (val) => val + 1).unwrap()); // prints: 5
  /// ```
  ///
  /// **Note**: Unlike Rust's
  /// [Result.map_or_else()](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or_else),
  /// this method returns a `Result` value. Given that [Result.map()] returns
  /// the mapped `Result` it just made sense for this method to do the same.
  ///
  /// See also:
  /// [Rust: `Result::map_or_else()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_or_else)
  Result<U, E> mapOrElse<U extends Object>(
          U Function() orFn, U Function(T v) mapFn) =>
      switch (this) {
        Ok(:T v) => Ok(mapFn(v)),
        Err() => Ok(orFn()),
      };

  /// Maps a `Result<T, E>` to a `Result<T, F>` using the given function with the
  /// held value.
  ///
  /// Returns:
  /// - [Ok<T, F>] if this [Result] is [Ok<T, E>].
  /// - [Err<T, F>] if this [Result] is [Err<T, E>].
  ///
  /// See also:
  /// [Rust: `Result::map_err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.map_err)
  Result<T, F> mapErr<F extends Object>(F Function(E e) mapFn) =>
      switch (this) {
        Ok(:T v) => Ok(v),
        Err(:E e) => Err(mapFn(e)),
      };

  /// Converts this `Result<T, E>` into an [Option<T>], discarding the held error
  /// value if this is [Err].
  ///
  /// Returns:
  /// - [Some<T>] if this `Result` is [Ok<T, E>].
  /// - [None<T>] if this `Result` is [Err<T, E>].
  ///
  /// See also:
  /// [Rust: `Result::ok()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.ok)
  Option<T> ok() => switch (this) {
        Ok(:T v) => Some(v),
        Err() => None(),
      };

  /// Converts this `Result<T, E>` into an [Option<E>], discarding the held value
  /// if this is [Ok].
  ///
  /// Returns:
  /// - [Some<E>] if this `Result` is [Err<T, E>].
  /// - [None<E>] if this `Result` is [Ok<T, E>].
  ///
  /// See also:
  /// [Rust: `Result::err()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.err)
  Option<E> err() => switch (this) {
        Ok() => None(),
        Err(:E e) => Some(e),
      };
}

/// A type that represents the successful [Result] of something.
///
/// Pattern matching is recommended for interacting with [Result] types.
///
/// ```dart
/// Result<int, String> foo = Ok(42);
///
/// if (foo case Ok(v: var bar)) {
///   print('Ok value: $bar');
/// }
/// ```
final class Ok<T extends Object, E extends Object> extends Result<T, E> {
  final T v;
  const Ok(this.v);
}

/// A type that represents the failure [Result] of something.
///
/// Pattern matching is recommended for interacting with [Result] types.
///
/// ```dart
/// Result<int, String> foo = Err('panic!');
///
/// if (foo case Err(e: var err)) {
///   print('Error value: $err');
/// }
/// ```
final class Err<T extends Object, E extends Object> extends Result<T, E> {
  final E e;
  const Err(this.e);
}

/// Provides the `flatten()` method to [Result] type values that hold another [Result].
extension ResultFlatten<T extends Object, E extends Object>
    on Result<Result<T, E>, E> {
  /// Flattens a nested `Result` type value one level.
  ///
  /// Returns:
  /// - [Ok<T, E>] if this `Result` is [Ok<Result<T, E>, E>]
  /// - [Err<T, E>] if this `Result` is [Err<Result<T, E>. E>]
  ///
  /// See also:
  /// [Rust: `Result::flatten()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.flatten)
  Result<T, E> flatten() => andThen(identity);
}

/// Provides the `transpose()` method to [Result] type values that hold an [Option] value.
extension ResultTranspose<T extends Object, E extends Object>
    on Result<Option<T>, E> {
  /// Transposes this `Result<Option<T>, E>` into an [Option<Result<T, E>>].
  ///
  /// Returns:
  /// - [Some<Ok<T, E>>] if this `Result` is [Ok<Some<T>, E>].
  /// - [None<Result<T, E>>] if this `Result` is [Ok<None<T>, E>].
  /// - [Some<Err<T, E>>] if this `Result` is [Err<Option<T>, E>].
  ///
  /// ```dart
  /// Result<Option<int>, String> a = Ok(Some(1));
  /// Option<Result<int, String>> b = Some(Ok(1));
  ///
  /// print(a.transpose() == b); // prints: true
  /// ```
  ///
  /// See also:
  /// [Rust: `Result::transpose()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.transpose)
  Option<Result<T, E>> transpose() => switch (this) {
        Ok(v: Some(:T v)) => Some(Ok(v)),
        Ok(v: None()) => None(),
        Err(:E e) => Some(Err(e)),
      };
}

/// Provides `call` functionality to [Future] values that complete with a [Result]
/// type value.
extension ResultFutureUnwrap<T extends Object, E extends Object>
    on Future<Result<T, E>> {
  /// Allows calling a `Future<Result<T, E>>` value like a function, transforming
  /// it into a [Future] that unwraps the returned `Result` value.
  ///
  /// **Warning**: This is an *unsafe* operation. A [ResultError] will be thrown
  /// if this operation is used on a [Future] returning an [Err] value when that
  /// [Future] completes. You can take advantage of this safely via [catchResultAsync].
  ///
  /// ```dart
  /// Future<Result<int, String>> resultReturn() async {
  ///   return Ok(1);
  /// }
  ///
  /// int foo = await resultReturn()();
  ///
  /// print(foo) // prints: 1
  /// ```
  ///
  /// See also:
  /// [Rust: `Result::unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap)
  Future<T> call() async => (await this).unwrap();
}

/// Provides `call` functionality to [FutureOr] values that complete with a [Result]
/// type value.
extension ResultFutureOrUnwrap<T extends Object, E extends Object>
    on FutureOr<Result<T, E>> {
  /// Allows calling a `FutureOr<Result<T, E>>` value like a function, transforming
  /// it into a [Future] that unwraps the returned `Result` value.
  ///
  /// **Warning**: This is an *unsafe* operation. A [ResultError] will be thrown
  /// if this operation is used on a [FutureOr] containing an [Err] value when that
  /// [FutureOr] completes. You can take advantage of this safely via [catchResultAsync].
  ///
  /// ```dart
  /// Future<Result<int, String>> resultReturn() {
  ///   return Ok(1);
  /// }
  ///
  /// int foo = await resultReturn()();
  ///
  /// print(foo) // prints: 1
  /// ```
  ///
  /// See also:
  /// [Rust: `Result::unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap)
  Future<T> call() async => (await this).unwrap();
}
