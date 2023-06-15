import 'package:test/test.dart';
import 'package:option_result/result.dart';

void main () {
	group('Result:', () {
		test('Should return expected values for isOk()/isErr()', () {
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

		test('Should return expected values from unwrapOr()', () {
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

		test('Should create expected Results via Result.from()', () {
			expect(Result.from('foo', 'err'), equals(Ok<String, String>('foo')));
			expect(Result<String, String>.from(null, 'err'), equals(Err<String, String>('err')));
		});

		test('Should throw ResultError when unwrapping Err()', () {
			expect(() => Err('foo bar baz').unwrap(), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should throw ResultError with unwrapErr() on Ok()', () {
			expect(() => Ok('foo bar baz').unwrapErr(), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should return expected values for Option#and()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('foo');

			expect(foo.and(Ok(2)), equals(Ok<int, String>(2)));
			expect(bar.and(Ok(2)), equals(Err<int, String>('foo')));

			expect(foo.and(Ok('foo')), equals(Ok<String, String>('foo')));
			expect(bar.and(Ok('baz')), equals(Err<String, String>('foo')));
		});

		test('Should return expected values for Option#andThen()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('foo');

			expect(foo.andThen((value) => Ok(value * 2)), equals(Ok<int, String>(2)));
			expect(bar.andThen((value) => Ok(value * 2)), equals(Err<int, String>('foo')));

			expect(foo.andThen((value) => Ok(value.toString())), equals(Ok<String, String>('1')));
			expect(bar.andThen((value) => Ok(value.toString())), equals(Err<String, String>('foo')));
		});

		test('Should return expected results for Result#map()', () {
			Result<int, String> foo = Ok(5);

			expect(foo.map((value) => value * 10), equals(Ok<int, String>(50)));
			expect(foo.map((value) => value.toString()), equals(Ok<String, String>('5')));

			expect(foo.map((value) => [value]), equals(TypeMatcher<Ok<List<int>, String>>()));

			// Check the wrapped List directly because two Results holding
			// different references to visibly identical lists aren't equatable
			expect(foo.map((value) => [value]).unwrap(), equals([5]));
		});

		test('Should return expected results for Result#mapErr()', () {
			Result<int, String> foo = Err('foo');

			expect(foo.mapErr((value) => value * 3), equals(Err<int, String>('foofoofoo')));
			expect(foo.mapErr((value) => value.toUpperCase()), equals(Err<int, String>('FOO')));

			expect(foo.mapErr((value) => [value]), equals(TypeMatcher<Err<int, List<String>>>()));

			// Check the wrapped List directly because two Results holding
			// different references to visibly identical lists aren't equatable
			expect(foo.mapErr((value) => [value]).unwrapErr(), equals(['foo']));
		});
	});
}
