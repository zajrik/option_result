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
the use of Dart's new exhaustive pattern matching to provide a familiar experience
while working with `Option` and `Result` type values.

> This package is a work-in-progress.

## Key differences

- `Option` and `Result` types provided by this library are immutable. All composition
methods either return new instances or the same instance if applicable, and methods
for inserting/replacing values are not provided.
<br><br>
  The benefits of immutability speak for themselves, but this also allows compile-time
`const` `Option` and `Result` values which can help improve application performance.
<br><br>
- This library lacks all of the methods Rust's `Option` and `Result` types have
that are related to `ref`, `deref`, `mut`, `pin`, `clone`, and `copy` due to not
being applicable to Dart as a higher-level language.
<br><br>
- The [Option.filter()](https://doc.rust-lang.org/std/option/enum.Option.html#method.filter)
method has been renamed `where()` to be more idiomatic to Dart.

## Getting started

Add the dependency to your `pubspec.yaml` file in your Dart/Flutter project:

```yaml
dependencies:
  option_result: ^0.1.0-dev-3
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

## Additional information

This library was written largely because I didn't like the way other libraries with
similar goals would leverage higher-order functions for faux-pattern-matching. Now
that Dart has real pattern matching I wanted to use something that leverages that,
but couldn't find anything that really fit my needs, nor my appreciation of Rust's
implementation.
