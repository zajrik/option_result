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

## option_result ![Test status](https://github.com/zajrik/option_result/actions/workflows/test.yaml/badge.svg) [![codecov](https://codecov.io/gh/zajrik/option_result/branch/main/graph/badge.svg?token=OMC42NL71B)](https://codecov.io/gh/zajrik/option_result)
`option_result` is a lightweight Dart library for `Option` and `Result` types. Inspired
by Rust, leveraging Dart 3's new pattern matching features and `sealed class` exhaustive
switch mechanics to provide as close to Rust's `Option`/`Result` experience as possible
without going so deep as to implement every single utility method Rust provides.

> This package is a work-in-progress.

## Getting started

Add the dependency to your `pubspec.yaml` file in your Dart/Flutter project:

```yaml
dependencies:
  option_result: ^0.0.1-dev-8
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
