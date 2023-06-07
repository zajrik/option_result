import 'package:result_option/result_option.dart';
import 'package:test/test.dart';

void main() {
	group('Result:', () {
		test('Should return appropriate values for isOk()/isErr()', () {
			expect(Ok(null).isOk(), equals(true));
			expect(Ok(null).isErr(), equals(false));
			expect(Err(null).isOk(), equals(false));
			expect(Err(null).isErr(), equals(true));
		});

		test('Should hold a simple Ok value', () {
			expect(Ok('foo bar baz').unwrap(), equals('foo bar baz'));
			expect(Ok(42).unwrap(), equals(42));
			expect(Ok(false).unwrap(), equals(false));
		});

		test('Should hold a simple Err value', () {
			expect(Err('foo bar baz').unwrapErr(), equals('foo bar baz'));
			expect(Err(42).unwrapErr(), equals(42));
			expect(Err(false).unwrapErr(), equals(false));
		});

		test('Should hold a complex Ok value', () {
			expect(Ok({'foo': 'bar', 'baz': 42}).unwrap(), equals({'foo': 'bar', 'baz': 42}));
			expect(Ok(['foo', 42, true]).unwrap(), equals(['foo', 42, true]));
		});

		test('Should hold a complex Err value', () {
			expect(Err({'foo': 'bar', 'baz': 42}).unwrapErr(), equals({'foo': 'bar', 'baz': 42}));
			expect(Err(['foo', 42, true]).unwrapErr(), equals(['foo', 42, true]));
		});

		test('Should return appropriate value from unwrapOr()', () {
			expect(Ok(1).unwrapOr(2), equals(1));
			expect(Err(1).unwrapOr(2), equals(2));
		});

		test('Should equate equatable Results', () {
			expect(Ok('foo') == Ok('foo'), equals(true));
			expect(Err('foo') == Err('foo'), equals(true));

			Map<String, dynamic> foo = {'foo': 'bar', 'baz': 42};
			expect(Ok(foo) == Ok(foo), equals(true));
		});

		test('Should throw ResultError when unwrapping Err()', () {
			expect(() => Err('foo bar baz').unwrap(), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should propagate Err() values via propagateResult', () {
			expect(propagateResult<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + bar.unwrap());
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should throw ResultError when propagating a mismatched Err() type via propagateResult', () {
			expect(() => propagateResult(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultError when erroring on unwrapErr() on Ok() via propagateResult', () {
			expect(() => propagateResult<int, String>(() {
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

		test('Should propagate Err() values via propagateResultAsync', () async {
			expect(await propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<int, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + bar.unwrap());
			}), equals(Err<int, String>('foo bar baz')));
		});

		test('Should throw ResultError when propagating a mismatched Err() type via propagateResultAsync', () {
			expect(() => propagateResultAsync<int, String>(() {
				Result<int, String> foo = Ok(1);
				Result<bool, String> bar = Err('foo bar baz');
				return Ok(foo.unwrap() + (bar.unwrap() ? 1 : 2));
			}), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should rethrow ResultError when erroring on unwrapErr() on Ok() via propagateResultAsync', () {
			expect(() => propagateResultAsync<int, String>(() {
				return Ok(Ok(1).unwrapErr());
			}), throwsA(TypeMatcher<ResultError>()));
		});
	});

	group('Option:', () {
		test('Should return appropriate values for isSome()/isNone()', () {
			expect(Some(null).isSome(), equals(true));
			expect(Some(null).isNone(), equals(false));
			expect(None().isSome(), equals(false));
			expect(None().isNone(), equals(true));
		});

		test('Should hold a simple value', () {
			expect(Some('foo bar baz').unwrap(), equals('foo bar baz'));
			expect(Some(42).unwrap(), equals(42));
			expect(Some(false).unwrap(), equals(false));
		});

		test('Should hold a complex value', () {
			expect(Some({'foo': 'bar', 'baz': 42}).unwrap(), equals({'foo': 'bar', 'baz': 42}));
		});

		test('Should return appropriate value from unwrapOr()', () {
			expect(Some(1).unwrapOr(2), equals(1));
			expect(None().unwrapOr(2), equals(2));
		});

		test('Should equate equatable Options', () {
			expect(Some('foo') == Some('foo'), equals(true));
			expect(None() == None(), equals(true));

			Map<String, dynamic> foo = {'foo': 'bar', 'baz': 42};
			expect(Some(foo) == Some(foo), equals(true));
		});

		test('Should throw OptionError when unwrapping None()', () {
			expect(() => None().unwrap(), throwsA(TypeMatcher<OptionError>()));
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
	});
}
