import 'package:test/test.dart';
import 'package:option_result/option_result.dart';

void main() {
	group('Option helpers:', () {
		test('Should propagate None() via propagateOption', () {
			expect(propagateOption<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(foo.unwrap() + bar.unwrap());
			}), equals(None<int>()));

			expect(~() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(foo.unwrap() + bar.unwrap());
			}, equals(None<int>()));
		});

		test('Should propagate None() via propagateOptionAsync', () async {
			expect(await propagateOptionAsync<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(foo.unwrap() + bar.unwrap());
			}), equals(None<int>()));
		});

		test('Should propagate None() via ~ as a propagation shortcut', () {
			expect(~() => Some(None().unwrap()), equals(None()));
		});

		test('Should propagate None() via ~ as an async propagation shortcut', () async {
			expect(await ~() async => Some(None().unwrap()), equals(None()));
		});

		test('Should propagate None() using ~ in propagateOption', () {
			expect(propagateOption<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(~foo + ~bar);
			}), equals(None<int>()));
		});

		test('Should propagate None() using ~ in propagateOptionAsync', () async {
			expect(await propagateOptionAsync<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(~foo + ~bar);
			}), equals(None<int>()));
		});

		test('Should rethrow any other kind of error/exception thrown inside propagateOption', () {
			expect(() => propagateOption(() => throw RangeError('foo')), throwsRangeError);
			expect(() => propagateOption(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => propagateOption(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should rethrow any other kind of error/exception thrown inside propagateOptionAsync', () {
			expect(() => propagateOptionAsync(() => throw RangeError('foo')), throwsRangeError);
			expect(() => propagateOptionAsync(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => propagateOptionAsync(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should rethrow OptionErrors thrown by Option#expect() inside propagateOption', () {
			expect(() => propagateOption(() => None().expect('foo')), throwsA(TypeMatcher<OptionError>()));
		});

		test('Should rethrow OptionErrors thrown by Option#expect() inside propagateOptionAsync', () {
			expect(() => propagateOptionAsync(() => None().expect('foo')), throwsA(TypeMatcher<OptionError>()));
		});
	});

	group('Result helpers:', () {
		test('Should propagate Err() values via propagateResult', () {
			expect(propagateResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + bar.unwrap());
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should propagate Err() values via propagateResultAsync', () async {
			expect(await propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + bar.unwrap());
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should propagate Err() via ~ as a propagation shortcut', () {
			expect(~() => Ok<dynamic, String>(Err('foo').unwrap()), equals(Err('foo')));
		});

		test('Should propagate Err() via ~ as an async propagation shortcut', () async {
			expect(await ~() async => Ok<dynamic, String>(Err('foo').unwrap()), equals(Err('foo')));
		});

		test('Should propagate Err() using ~ in propagateResult', () {
			expect(propagateResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo');
				return Ok(~foo + ~bar);
			}), equals(Err<int, String>('foo')));
		});

		test('Should propagate Err() using ~ in propagateResultAsync', () async {
			expect(await propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo');
				return Ok(~foo + ~bar);
			}), equals(Err<int, String>('foo')));
		});

		test('Should rethrow ResultError when erroring on unwrapErr() on Ok() via propagateResult', () {
			expect(() => propagateResult<int, String>(() {
				return Ok(Ok(1).unwrapErr());
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultError when erroring on unwrapErr() on Ok() via propagateResultAsync', () {
			expect(() => propagateResultAsync<int, String>(() {
				return Ok(Ok(1).unwrapErr());
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow any other kind of error/exception thrown inside propagateResult', () {
			expect(() => propagateResult(() => throw RangeError('foo')), throwsRangeError);
			expect(() => propagateResult(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => propagateResult(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should rethrow any other kind of error/exception thrown inside propagateResultAsync', () {
			expect(() => propagateResultAsync(() => throw RangeError('foo')), throwsRangeError);
			expect(() => propagateResultAsync(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => propagateResultAsync(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should repackage propagated Err()s as long as the Err() type (E) matches via propagateResult', () {
			expect(propagateResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should repackage propagated Err()s as long as the Err() type `E` matches via propagateResultAsync', () async {
			expect(await propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should throw ResultError when propagated Err() type `E` does not match expected type via propagateResult', () {
			expect(() => propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, int> bar = Err(3);
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should throw ResultError when propagated Err() type `E` does not match expected type via propagateResultAsync', () {
			expect(() => propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, int> bar = Err(3);
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expect() inside propagateOption', () {
			expect(() => propagateResult(() => Err('foo').expect('bar')), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expect() inside propagateOptionAsync', () {
			expect(() => propagateResultAsync(() => Err('foo').expect('bar')), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expectErr() inside propagateOption', () {
			expect(() => propagateResult(() => Ok('foo').expectErr('bar')), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expectErr() inside propagateOptionAsync', () {
			expect(() => propagateResultAsync(() => Ok('foo').expectErr('bar')), throwsA(TypeMatcher<ResultError>()));
		});
	});
}
