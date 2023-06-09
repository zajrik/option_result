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
		});

		test('Should propagate None() via propagateOptionAsync', () async {
			expect(await propagateOptionAsync<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(foo.unwrap() + bar.unwrap());
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

		test('Should throw ResultError when propagating a mismatched Err() type via propagateResult', () {
			expect(() => propagateResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should throw ResultError when propagating a mismatched Err() type via propagateResultAsync', () {
			expect(() => propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});
	});
}
