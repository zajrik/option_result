import 'package:option_result/option_result.dart';
import 'package:test/test.dart';

void main() {
	group('Option:', () {
		test('Should return appropriate values for isSome()/isNone()', () {
			expect(Some(null).isSome(), equals(true));
			expect(Some(null).isNone(), equals(false));
			expect(None().isSome(), equals(false));
			expect(None().isNone(), equals(true));
		});

		test('Should hold and unwrap simple values', () {
			expect(Some('foo bar baz').unwrap(), equals('foo bar baz'));
			expect(Some(42).unwrap(), equals(42));
			expect(Some(false).unwrap(), equals(false));
		});

		test('Should hold and unwrap complex values', () {
			expect(Some({'foo': 'bar', 'baz': 42}).unwrap(), equals({'foo': 'bar', 'baz': 42}));
			expect(Some(['foo', 'bar', 'baz']).unwrap(), equals(['foo', 'bar', 'baz']));
		});

		test('Should return appropriate values from unwrapOr()', () {
			expect(Some(1).unwrapOr(2), equals(1));
			expect(None().unwrapOr(2), equals(2));
		});

		test('Should equate equatable Options', () {
			expect(Some('foo') == Some('foo'), equals(true));
			expect(None() == None(), equals(true));

			Map<String, dynamic> foo = {'foo': 'bar', 'baz': 42};

			// They share the same reference to foo
			expect(Some(foo) == Some(foo), equals(true));
		});

		test('Should create appropriate Options via Option.from()', () {
			expect(Option.from('foo'), equals(Some('foo')));
			expect(Option<int>.from(null), equals(None<int>()));
		});

		test('Should not equate Options with equatable values but mismatched types', () {
			Option<int> foo = Some(1);
			Option<num> bar = Some(1);

			expect(foo == bar, equals(false));

			Option<int> foo2 = None();
			Option<bool> bar2 = None();

			// ignore: unrelated_type_equality_checks
			expect(foo2 == bar2, equals(false));
		});

		test('Should throw OptionError when unwrapping None()', () {
			expect(() => None().unwrap(), throwsA(TypeMatcher<OptionError>()));
		});

		test('Option#filter() should return appropriate values', () {
			Option<int> foo = Some(5);

			expect(foo.filter((value) => value < 10), equals(Some(5)));
			expect(foo.filter((value) => value > 6), equals(None<int>()));
		});
	});

	group('Result:', () {
		test('Should return appropriate values for isOk()/isErr()', () {
			expect(Ok(null).isOk(), equals(true));
			expect(Ok(null).isErr(), equals(false));
			expect(Err(null).isOk(), equals(false));
			expect(Err(null).isErr(), equals(true));
		});

		test('Should hold and unwrap simple Ok values', () {
			expect(Ok('foo bar baz').unwrap(), equals('foo bar baz'));
			expect(Ok(42).unwrap(), equals(42));
			expect(Ok(false).unwrap(), equals(false));
		});

		test('Should hold and unwrap simple Err values (unwrapErr)', () {
			expect(Err('foo bar baz').unwrapErr(), equals('foo bar baz'));
			expect(Err(42).unwrapErr(), equals(42));
			expect(Err(false).unwrapErr(), equals(false));
		});

		test('Should hold and unwrap complex Ok values', () {
			expect(Ok({'foo': 'bar', 'baz': 42}).unwrap(), equals({'foo': 'bar', 'baz': 42}));
			expect(Ok(['foo', 42, true]).unwrap(), equals(['foo', 42, true]));
		});

		test('Should hold and unwrap complex Err values (unwrapErr)', () {
			expect(Err({'foo': 'bar', 'baz': 42}).unwrapErr(), equals({'foo': 'bar', 'baz': 42}));
			expect(Err(['foo', 42, true]).unwrapErr(), equals(['foo', 42, true]));
		});

		test('Should return appropriate values from unwrapOr()', () {
			expect(Ok(1).unwrapOr(2), equals(1));
			expect(Err(1).unwrapOr(2), equals(2));
		});

		test('Should equate equatable Results', () {
			expect(Ok('foo') == Ok('foo'), equals(true));
			expect(Err('foo') == Err('foo'), equals(true));

			Map<String, dynamic> foo = {'foo': 'bar', 'baz': 42};
			expect(Ok(foo) == Ok(foo), equals(true));

			Result<int, String> bar = Ok(1);
			Result<int, String> baz = Ok(1);

			expect(bar == baz, equals(true));

			baz = Ok(2);

			expect(bar == baz, equals(false));
		});

		test('Should not equate Results with equatable values but mismatched types', () {
			Result<int, String> foo = Ok(1);
			Result<int, int> bar = Ok(1);

			// ignore: unrelated_type_equality_checks
			expect(foo == bar, equals(false));
		});

		test('Should create appropriate Results via Result.from()', () {
			expect(Result.from('foo', 'err'), equals(Ok<String, String>('foo')));
			expect(Result<String, String>.from(null, 'err'), equals(Err<String, String>('err')));

			Option<int> foo = Some(7);
			Option<int> bar = None();

			print(foo.runtimeType.hashCode == bar.runtimeType.hashCode);
		});

		test('Should throw ResultError when unwrapping Err()', () {
			expect(() => Err('foo bar baz').unwrap(), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should throw ResultError with unwrapErr() on Ok()', () {
			expect(() => Ok('foo bar baz').unwrapErr(), throwsA(TypeMatcher<ResultError>()));
		});
	});

	group('Helpers:', () {
		// Option helpers
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

		// Result helpers
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
