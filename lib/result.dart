/// This is the `result` library, containing only the [Result] type and its helpers.
///
/// This library can be imported via:
///
/// ```dart
/// import 'package:option_result/result.dart';
/// ```
///
/// If you want to import both `Option` and `Result` types, consider importing the
/// combined library:
///
/// ```dart
/// import 'package:option_result/option_result.dart';
/// ```
library result;

import 'dart:async';

import 'option.dart';

import 'src/util.dart';

part 'src/result/result.dart';
part 'src/result/result_error.dart';
part 'src/result/result_helpers.dart';
