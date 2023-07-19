<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## option_result [![Test status](https://github.com/zajrik/option_result/actions/workflows/test.yaml/badge.svg)](https://github.com/zajrik/option_result/actions/workflows/test.yaml) [![codecov](https://codecov.io/gh/zajrik/option_result/branch/main/graph/badge.svg?token=OMC42NL71B)](https://codecov.io/gh/zajrik/option_result)

`option_result` is a lightweight library with the goal of bringing Rust's
[Option](https://doc.rust-lang.org/stable/std/option/) and
[Result](https://doc.rust-lang.org/std/result/) types to Dart.

This library aims to provide as close to a 1:1 experience in Dart as possible to
Rust's implementation of these types, carrying over all of the methods for composing
`Option` and `Result` values (`and_then()`, `or_else()`, `map()`, etc.) and allowing
the use of Dart 3's new exhaustive pattern matching to provide a familiar experience
while working with `Option` and `Result` type values.

## Overview

### Option

`Option` types represent the presence (`Some`) or absence (`None`) of a value.

Dart handles this pretty well on its own via `null` and a focus on null-safety built
in to the compiler and analyzer, but we can do better.

The advantage of `Option` types over nullable types lies in their composability.
`Option` type values have many methods that allow composing many `Option`-returning
operations together and helpers for propagating `None` values in larger operations
without the need for repetitive null-checking.

This supports writing clean, concise, and most importantly, *safe* code.

```dart
Option<int> multiplyBy5(int i) => Some(i * 5);
Option<int> divideBy2(int i) => switch (i) {
  0 => None(),
  _ => Some(i ~/ 2)
};

Option<int> a = Some(10);
Option<int> b = None();

Option<int> c = a.andThen(divideBy2).andThen(multiplyBy5); // Some(25)
Option<int> d = b.andThen(divideBy2).andThen(multiplyBy5); // None()
```

For safety, operations culminating in an `Option` that make use of other `Option`
values in their logic where the outcome is dependent on those `Option` values can
benefit from `None` value propagation via `catchOption()`:

```dart
// If user or email is None when unwrapped, catchOption will exit early, returning None
Option<String> getUserEmailLowerCase(int id) => catchOption(() {
  Option<User> user = getUser(id);
  // Unwrap user easily here by calling it like a function, as an alternative to:
  // Option<String> email = user.unwrap().email;
  Option<String> email = user().email;

  return Some(email().toLowerCase());
});

Option<String> email = getUserEmailLowerCase(12345);

switch (email) {
  case Some(value: String value): print('User email: $value');
  case None(): print('User does not have a valid email');
}
```

### Result

`Result` types represent the result of some operation, either success (`Ok`), or
failure (`Err`), and both variants can hold data.

This promotes safe handling of error values without the need for try/catch blocks
while also providing composability like `Option` via methods for composing `Result`-returning
operations together and helpers for propagating `Err` values within larger operations
without the need for repetitive error catching, checking, and rethrowing.

Again, like `Option`, this helps promote clean, concise, and safe code.

```dart
Result<int, String> multiplyBy5(int i) => Ok(i * 5);
Result<int, String> divideBy2(int i) => switch (i) {
  0 => Err('divided by 0'),
  _ => Ok(i ~/ 2)
};

Result<int, String> a = Ok(10);
Result<int, String> b = Ok(0);
Result<int, String> c = Err('foo');

Result<int, String> d = a.andThen(divideBy2).andThen(multiplyBy5); // Ok(25)
Result<int, String> e = b.andThen(divideBy2).andThen(multiplyBy5); // Err('divided by 0')
Result<int, String> f = c.andThen(divideBy2).andThen(multiplyBy5); // Err('foo')
```

And, you guessed it, like `Option`, `Result` types can also benefit from safe propagation
of their `Err` values using `catchResult()`:

```dart
// If user or email is Err when unwrapped, catchResult will exit early, returning Err
Result<String, String> getUserEmailLowerCase(int id) => catchResult(() {
  Result<User, String> user = getUser(id);
  // Unwrap user easily here by calling it like a function, as an alternative to:
  // Result<String, String> email = user.unwrap().getEmail();
  Result<String, String> email = user().getEmail();

  return Ok(email().toLowerCase());
});

Result<String, String> email = getUserEmailLowerCase(12345);

switch (email) {
  case Ok(value: String value): print('User email: $value');
  case Err(value: String err): print('Error fetching email: $err');
}
```

But `Result` doesn't always have to concern data. A `Result` can be used strictly
for error handling, where an `Ok` simply means there was no error and you can safely
continue. In Rust this is typically done by returning the
[unit](https://doc.rust-lang.org/std/primitive.unit.html) type `()` as `Result<(), E>`
and the same can be done in Dart with an empty `Record` via `()`.

```dart
Result<(), String> failableOperation() {
  if (someReasonToFail) {
    return Err('Failure');
  }

  return Ok(());
}

Result<(), String> err = failableOperation();

if (err case Err(value: String error)) {
  print(error);
  return;
}

// No error, continue...
```

To further support this, just like how you can unwrap `Option` and `Result` values
by calling them like a function, an extension for `Future<Option<T>>` and `Future<Result<T, E>>`
is provided to allow calling them like a function as well which will transform the
future into a future that unwraps the resulting `Option` or `Result` when completing.

*(This also applies to `FutureOr` values.)*

```dart
// Here we have two functions that return Result<(), String>, one of which is a Future.
// We can wrap them in a catchResult block (async in this case) and call them like a function
// to unwrap them, discarding the unit value if Ok, or propagating the Err value otherwise.
Result<(), String> err = catchResultAsync(() async {
  await failableOperation1()();
  failableOperation2()();

  return Ok(());
});

if (err case Err(value: String error)) {
  print(error);
  return;
}
```

*Note that just like how `unit` has one value in Rust, empty `Record` values in
Dart are optimized to the same runtime constant reference so there is no performance
or memory overhead when using `()` as a `unit` type.*

## Key differences from Rust

- `Option` and `Result` types provided by this library are immutable. All composition
methods either return new instances or the same instance unmodified if applicable, and
methods for inserting/replacing values are not provided.
<br><br>
  The benefits of immutability speak for themselves, but this also allows compile-time
`const` `Option` and `Result` values which can help improve application performance.
<br><br>
- This library lacks all of the methods Rust's `Option` and `Result` types have
that are related to `ref`, `deref`, `mut`, `pin`, `clone`, and `copy` due to not
being applicable to Dart as a higher-level language.
<br><br>
- The [Option.filter()](https://doc.rust-lang.org/std/option/enum.Option.html#method.filter)
method has been renamed `where()` to be more Dart-idiomatic.
<br><br>
- The `Option` and `Result` methods `mapOr`, `mapOrElse` return `Option<U>` and `Result<U, E>`
respectively to aid composition of `Option` and `Result` values. The encapsulated
values of these types should never leave the context of `Option` or `Result` unless
explicitly unwrapped via the designated methods (`unwrap()`, `expect()`, etc.).
<br><br>
- `None()`/`Err()` propagation is not supported at the language-level in Dart since
there's no concept of it so it's not quite as ergonomic as Rust, but is still quite
comfy and easily managed via the provided helpers.

## Getting started

Add the dependency to your `pubspec.yaml` file in your Dart/Flutter project:

```yaml
dependencies:
  option_result: ^3.1.1
```

Or via git:

```yaml
dependencies:
  option_result:
    git: https://github.com/zajrik/option_result.git
```

Then run `dart pub get` or `flutter pub get` and import the library:

```dart
import 'package:option_result/option_result.dart';
// or import the separate types individually:
import 'package:option_result/option.dart';
import 'package:option_result/result.dart';
```

## Basic Usage

```dart
// Assume getUser() returns some sort of User object
Result<User, String> user = await getUser(id: 12345);

if (user case Err(value: String error)) {
  print('Error retrieving user: $error');
  return;
}

// Assume the User object has an email field of type Option<String>
Option<String> email = user.unwrap().email;

if (email case Some(value: String address)) {
  print('User email: $address');
} else {
  print('User has no email set.');
}

// Alternative to the above using a switch expression for pattern matching
print(switch (email) {
  Some(value: String address) => 'User email: $address',
  None() => 'User has no email set.'
});

// Pattern matching with switch is exhaustive for Option and Result, so the compiler
// will give you warnings/errors to make sure you're providing cases for all potential
// values for Some()/Ok(), either directly or via a default case, and for None()/Err(),
// again either directly or via a default case
```

## Pattern-matching verbosity

All of the prior examples in this document are using the most verbose syntax for
pattern matching possible, but Dart does provide some sugar to make our lives as
developers a little easier and this library provides a bit of its own sugar too.

Consider the following if-case:

```dart
if (result case Err(value: String value)) {}
```

This example checks if `result` is `Err` and that its `value` field contains a `String`
type value, which it binds to the scoped variable of the same name, `value`.

This level of verbosity is necessary if you want to rebind the `value` field to
a scoped variable of a different name like so:

```dart
if (result case Err(value: String foo)) {}
```

But if you're comfortable with your scoped variable being named `value` then you can
make use of the field-access shorthand that Dart provides:

```dart
if (result case Err(:String value)) {}
if (result case Err(:final value)) {}
if (result case Err(:var value)) {}
```

These are all functionally identical but the lack of repetition really cleans things up.

To clean things up even further, the `Option` and `Result` types have a few shorthand
getters you can take advantage of:

```dart
if (result case Ok(:var v)) {}
if (result case Ok(:var val)) {}
if (result case Err(:var e)) {}
if (result case Err(:var error)) {}
// Err types also have v, val
```

These can also be used for rebinding:

```dart
if (result case Err(e: var foo)) {}
```

The exhaustive list of `value` field shorthand getters for `Option` and `Result`
is as follows:

- `Option`
  - `Some`: `v`, `val`
- `Result`
  - `Ok`: `v`, `val`
  - `Err`: `v`, `val`, `e`, `error`
    - Ideally `err` would be included but is not possible due to the `err` method
    found on `Result` types

## Potential extension conflicts

This library provides 4 total class extensions on the following types:

- `Future<Option<T>>`
- `FutureOr<Option<T>>`
- `Future<Result<T, E>>`
- `FutureOr<Result<T, E>>`

These extensions provide a `call()` method to allow calling these types like functions
to unwrap the underlying `Option` and `Result` types. In the event that any other
library provides a `call()` method on `Future`/`FutureOr` types that you need to
make use of instead, you can hide the following extensions from this library:

- `OptionFutureUnwrap`
- `OptionFutureOrUnwrap`
- `ResultFutureUnwrap`
- `ResultFutureOrUnwrap`

You can accomplish this like so:

```dart
// Whitespace doesn't matter here, just keeping it clean
import 'package:option_result/option_result.dart'
  hide
    OptionFutureUnwrap,
    OptionFutureOrUnwrap,
    ResultFutureUnwrap,
    ResultFutureOrUnwrap;

// Or if you're only importing one of the types from the package:
import 'package:option_result/option.dart'
  hide
    OptionFutureUnwrap,
    OptionFutureOrUnwrap;
```

## Similar packages

I started writing this library because there are many options (pun-intended) out
there that accomplished similar goals but none of them stuck out to me at a glance
as something that fit my needs. Pretty much all of them provided faux-pattern-matching
via higher-order functions which I didn't care for, and I wanted to be able to make
use of Dart 3's new exhaustive pattern matching which none of the libraries that
I could find provided at the time of starting this project.

- [oxidized](https://pub.dev/packages/oxidized) - Provides `Option` and `Result`
types and is smiliarly close to a 1:1 representation of Rust's implementation as
this library but with a much cooler name.
  - Supports Dart 3's exhaustive pattern matching as of v6.0.0. This feature was
  not available at the time of starting this project and probably would have prevented
  me from wanting to start it at all had it been 🤣
<br><br>

- [ruqe](https://pub.dev/packages/ruqe) - Provides `Option` and `Result` types,
as well as an `Either` type, which is like a `Result` type with extra steps.
<br><br>

- [either_option](https://pub.dev/packages/either_option) - Provides `Option` and
`Either` types.
<br><br>

- [crab](https://pub.dev/packages/crab) - Provides `Option` and `Result` types.
Has a cool name.
<br><br>

- [fpdart](https://pub.dev/packages/fpdart) - Functional programming in Dart. Very
thorougly documented. Provides `Option` and `Either` types and so much more. `sealed`
type support is in the works so expect proper pattern matching soon. 😎
<br><br>

- [dartz](https://pub.dev/packages/dartz) - Another functional programming library.
Predates `fpdart` but appears to no longer be receiving updates. Provides `Option`,
and `Either` types as well.
<br><br>
  Also has a cool name.

## Final thoughts

I've had a lot of fun writing this library. I haven't had a good project to work on
in quite some time so even if I'm the only person to ever end up using this, I'm still
content that I took the time to write it and put it out there. It was a nice exercise.

Functional programming in Dart is not my goal and never really was. I just like `Option`
and `Result` types for null/error handling. I always find myself thinking about them
whenever I try new languages without a similar concept.

With all of that said, if you're reading this: Thank you for taking the time to explore
this library, even if it's not what you need for your projects.
