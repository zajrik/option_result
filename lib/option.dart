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

import 'src/util.dart';

part 'src/option/option.dart';
part 'src/option/option_error.dart';
part 'src/option/option_helpers.dart';
