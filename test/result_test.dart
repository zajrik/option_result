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

		test('Should return expected values from Result#expect()', () {
			expect(Ok(1).expect('should be Ok()'), equals(1));
			expect(() => Err('foo').expect('Should be Ok()'), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should return expected values from Result#expectErr()', () {
			expect(Err(1).expectErr('should be Err()'), equals(1));
			expect(() => Ok('foo').expectErr('Should be Err()'), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should return expected values for Result#and()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.and(Ok(2)), equals(Ok<int, String>(2)));
			expect(bar.and(Ok(2)), equals(Err<int, String>('bar')));

			expect(foo.and(Ok('foo')), equals(Ok<String, String>('foo')));
			expect(bar.and(Ok('baz')), equals(Err<String, String>('bar')));
		});

		test('Should return expected values for Result#andThen()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.andThen((value) => Ok(value * 2)), equals(Ok<int, String>(2)));
			expect(bar.andThen((value) => Ok(value * 2)), equals(Err<int, String>('bar')));

			expect(foo.andThen((value) => Ok(value.toString())), equals(Ok<String, String>('1')));
			expect(bar.andThen((value) => Ok(value.toString())), equals(Err<String, String>('bar')));
		});

		test('Should return expected values for Result#or()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.or(Ok<int, String>(2)), equals(Ok<int, String>(1)));
			expect(bar.or(Ok<int, String>(2)), equals(Ok<int, String>(2)));

			expect(foo.or(Err(2)), equals(Ok<int, int>(1)));
			expect(bar.or(Err(2)), equals(Err<int, int>(2)));
		});

		test('Should return expected values for Result#orElse()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.orElse((value) => Err('$value baz')), equals(Ok<int, String>(1)));
			expect(bar.orElse((value) => Err('$value baz')), equals(Err<int, String>('bar baz')));

			expect(foo.orElse((_) => Err(2)), equals(Ok<int, int>(1)));
			expect(bar.orElse((_) => Err(2)), equals(Err<int, int>(2)));
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

		test('Should return expected values from Result#flatten()', () {
			Result<Result<Result<Result<int, String>, String>, String>, String> foo = Ok(Ok(Ok(Ok(1))));

			// Result.from() here because it won't equate Ok<Ok<T, E>, E> to Result<Result<T, E>, E>
			// but Result<Result<T, E>, E> compares fine. I assumed it was from the runtimeType
			// comparison in == but removing that still doesn't allow equals() to consider
			// the values the same here despite that fixing == for these cases.
			expect(foo.flatten().flatten().flatten(), equals(Ok<int, String>(1)));
			expect(foo.flatten().flatten(), equals(Result.from(Result.from(1, 'foo'), 'bar')));
			expect(foo.flatten(), equals(Result.from(Result.from(Result.from(1, 'foo'), 'bar'), 'baz')));

			var bar = Ok(Ok(Ok(Ok(1))));

			expect(bar.flatten().flatten().flatten(), equals(Ok(1)));
		});
	});
}
