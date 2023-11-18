/// This is the `option` library, containing only the [Option] type and its helpers.
///
/// This library can be imported via:
///
/// ```dart
/// import 'package:option_result/option.dart';
/// ```
///
/// If you want to import both `Option` and `Result` types, consider importing the
/// combined library:
///
/// ```dart
/// import 'package:option_result/option_result.dart';
/// ```
library option;

import 'dart:async';

import 'result.dart';

import 'util.dart';

part 'option/option.dart';
part 'option/option_error.dart';
part 'option/option_helpers.dart';
