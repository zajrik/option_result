import 'package:test/test.dart';
import 'package:option_result/option_result.dart';

void main() {
	group('Option helpers:', () {
		test('Should propagate None() via catchOption', () {
			expect(catchOption<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(foo.unwrap() + bar.unwrap());
			}), equals(None<int>()));
		});

		test('Should propagate None() via catchOptionAsync', () async {
			expect(await catchOptionAsync<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(foo.unwrap() + bar.unwrap());
			}), equals(None<int>()));
		});

		test('Should propagate None() using ~ in catchOption', () {
			expect(catchOption<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(~foo + ~bar);
			}), equals(None<int>()));
		});

		test('Should propagate None() using ~ in catchOptionAsync', () async {
			expect(await catchOptionAsync<int>(() {
				Option<int> foo = Some(1);
				Option<int> bar = None();
				return Some(~foo + ~bar);
			}), equals(None<int>()));
		});

		test('Should rethrow any other kind of error/exception thrown inside catchOption', () {
			expect(() => catchOption(() => throw RangeError('foo')), throwsRangeError);
			expect(() => catchOption(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => catchOption(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should rethrow any other kind of error/exception thrown inside catchOptionAsync', () {
			expect(() => catchOptionAsync(() => throw RangeError('foo')), throwsRangeError);
			expect(() => catchOptionAsync(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => catchOptionAsync(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should rethrow OptionErrors thrown by Option#expect() inside catchOption', () {
			expect(() => catchOption(() => None().expect('foo')), throwsA(TypeMatcher<OptionError>()));
		});

		test('Should rethrow OptionErrors thrown by Option#expect() inside catchOptionAsync', () {
			expect(() => catchOptionAsync(() => None().expect('foo')), throwsA(TypeMatcher<OptionError>()));
		});
	});

	group('Result helpers:', () {
		test('Should propagate Err() values via catchResult', () {
			expect(catchResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + bar.unwrap());
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should propagate Err() values via catchResultAsync', () async {
			expect(await catchResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + bar.unwrap());
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should propagate Err() using ~ in catchResult', () {
			expect(catchResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo');
				return Ok(~foo + ~bar);
			}), equals(Err<int, String>('foo')));
		});

		test('Should propagate Err() using ~ in catchResultAsync', () async {
			expect(await catchResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo');
				return Ok(~foo + ~bar);
			}), equals(Err<int, String>('foo')));
		});

		test('Should rethrow ResultError when erroring on unwrapErr() on Ok() via catchResult', () {
			expect(() => catchResult<int, String>(() {
				return Ok(Ok(1).unwrapErr());
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultError when erroring on unwrapErr() on Ok() via catchResultAsync', () {
			expect(() => catchResultAsync<int, String>(() {
				return Ok(Ok(1).unwrapErr());
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow any other kind of error/exception thrown inside catchResult', () {
			expect(() => catchResult(() => throw RangeError('foo')), throwsRangeError);
			expect(() => catchResult(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => catchResult(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should rethrow any other kind of error/exception thrown inside catchResultAsync', () {
			expect(() => catchResultAsync(() => throw RangeError('foo')), throwsRangeError);
			expect(() => catchResultAsync(() => throw ArgumentError('bar')), throwsArgumentError);
			expect(() => catchResultAsync(() => throw FormatException('baz')), throwsFormatException);
		});

		test('Should repackage propagated Err()s as long as the Err() type (E) matches via catchResult', () {
			expect(catchResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should repackage propagated Err()s as long as the Err() type `E` matches via catchResultAsync', () async {
			expect(await catchResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should throw ResultError when propagated Err() type `E` does not match expected type via catchResult', () {
			expect(() => catchResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, int> bar = Err(3);
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should throw ResultError when propagated Err() type `E` does not match expected type via catchResultAsync', () {
			expect(() => catchResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, int> bar = Err(3);
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expect() inside catchOption', () {
			expect(() => catchResult(() => Err('foo').expect('bar')), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expect() inside catchOptionAsync', () {
			expect(() => catchResultAsync(() => Err('foo').expect('bar')), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expectErr() inside catchOption', () {
			expect(() => catchResult(() => Ok('foo').expectErr('bar')), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultErrors thrown by Result#expectErr() inside catchOptionAsync', () {
			expect(() => catchResultAsync(() => Ok('foo').expectErr('bar')), throwsA(TypeMatcher<ResultError>()));
		});
	});
}
