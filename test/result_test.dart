import 'package:test/test.dart';
import 'package:option_result/option_result.dart';

void main () {
	group('Result:', () {
		test('Should provide a hashCode', () {
			expect(Ok(1).hashCode, equals(Object.hash('Ok()', 1)));
			expect(Err(1).hashCode, equals(Object.hash('Err()', 1)));
		});

		test('Should provide a string representation', () {
			expect(Ok(1).toString(), equals('Ok(1)'));
			expect(Ok('foo').toString(), equals('Ok(foo)'));
			expect(Ok({'foo': 'bar'}).toString(), equals('Ok({foo: bar})'));
			expect(Ok([1, 2, 3]).toString(), equals('Ok([1, 2, 3])'));
			expect(Ok({1, 2, 3}).toString(), equals('Ok({1, 2, 3})'));

			expect(Err(1).toString(), equals('Err(1)'));
			expect(Err('foo').toString(), equals('Err(foo)'));
			expect(Err({'foo': 'bar'}).toString(), equals('Err({foo: bar})'));
			expect(Err([1, 2, 3]).toString(), equals('Err([1, 2, 3])'));
			expect(Err({1, 2, 3}).toString(), equals('Err({1, 2, 3})'));
		});

		test('Should hold and unwrap simple Ok values', () {
			expect(Ok('foo bar baz').unwrap(), equals('foo bar baz'));
			expect(Ok(42).unwrap(), equals(42));
			expect(Ok(false).unwrap(), equals(false));
		});

		test('Should hold and unwrap simple Err values', () {
			expect(Err('foo bar baz').unwrapErr(), equals('foo bar baz'));
			expect(Err(42).unwrapErr(), equals(42));
			expect(Err(false).unwrapErr(), equals(false));
		});

		test('Should hold and unwrap complex Ok values', () {
			expect(Ok({'foo': 'bar', 'baz': 42}).unwrap(), equals({'foo': 'bar', 'baz': 42}));
			expect(Ok(['foo', 42, true]).unwrap(), equals(['foo', 42, true]));
		});

		test('Should hold and unwrap complex Err values', () {
			expect(Err({'foo': 'bar', 'baz': 42}).unwrapErr(), equals({'foo': 'bar', 'baz': 42}));
			expect(Err(['foo', 42, true]).unwrapErr(), equals(['foo', 42, true]));
		});

		test('Should unwrap values via shorthand getters', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			if (foo case Ok(:int v)) { expect(v, equals(1)); }
			if (foo case Ok(:int val)) { expect(val, equals(1)); }
			if (bar case Err(:String v)) { expect(v, equals('bar')); }
			if (bar case Err(:String val)) { expect(val, equals('bar')); }
			if (bar case Err(:String e)) { expect(e, equals('bar')); }
			if (bar case Err(:String error)) { expect(error, equals('bar')); }
		});

		test('Should create expected Results via Result.from()', () {
			expect(Result.from('foo', 'err'), equals(Ok<String, String>('foo')));
			expect(Result<String, String>.from(null, 'err'), equals(Err<String, String>('err')));
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

			// Irrelevant types are elided (E for Ok, T for Err), only value matters

			// ignore: unrelated_type_equality_checks
			expect(Ok<int, String>(1) == Ok<int, int>(1), equals(true));
			// ignore: unrelated_type_equality_checks
			expect(Err<int, String>('foo') == Err<bool, String>('foo'), equals(true));
		});

		test('Should throw ResultError when unwrapping Err()', () {
			expect(() => Err('foo bar baz').unwrap(), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should throw ResultError with unwrapErr() on Ok()', () {
			expect(() => Ok('foo bar baz').unwrapErr(), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should return expected values from Result#isOkAnd()', () {
			expect(Ok(1).isOkAnd((value) => value == 1), equals(true));
			expect(Ok(1).isOkAnd((value) => value >= 2), equals(false));
			expect(Err(1).isOkAnd((_) => true), equals(false));
		});

		test('Should return expected values from Result#isErrAnd()', () {
			expect(Err(1).isErrAnd((value) => value == 1), equals(true));
			expect(Err(1).isErrAnd((value) => value >= 2), equals(false));
			expect(Ok(1).isErrAnd((_) => true), equals(false));
		});

		test('Should return expected values from Result#unwrapOr()', () {
			expect(Ok(1).unwrapOr(2), equals(1));
			expect(Err(1).unwrapOr(2), equals(2));
		});

		test('Should return expected values from Result#unwrapOrElse()', () {
			expect(Ok(1).unwrapOrElse(() => 2), equals(1));
			expect(Err(1).unwrapOrElse(() => 2), equals(2));
		});

		test('Should return expected values from Result#expect()', () {
			expect(Ok(1).expect('should be Ok()'), equals(1));
			expect(() => Err('foo').expect('Should be Ok()'), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should return expected values from Result#expectErr()', () {
			expect(Err(1).expectErr('should be Err()'), equals(1));
			expect(() => Ok('foo').expectErr('Should be Err()'), throwsA(TypeMatcher<ResultError>()));
		});

		test('Should iterate over the held value via Result#iter()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('foo');

			for (int value in foo.iter()) {
				expect(value, equals(1));
			}

			bool called = false;
			void call() => called = true;

			// The call() function should not run since there's nothing to iterate
			// over in an Err() value
			for (int _ in bar.iter()) {
				call();
			}

			expect(called, equals(false));
		});

		test('Should return expected values from Result#and()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.and(Ok(2)), equals(Ok<int, String>(2)));
			expect(bar.and(Ok(2)), equals(Err<int, String>('bar')));

			expect(foo.and(Ok('foo')), equals(Ok<String, String>('foo')));
			expect(bar.and(Ok('baz')), equals(Err<String, String>('bar')));
		});

		test('Should return expected values from Result#andThen()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.andThen((value) => Ok(value * 2)), equals(Ok<int, String>(2)));
			expect(bar.andThen((value) => Ok(value * 2)), equals(Err<int, String>('bar')));

			expect(foo.andThen((value) => Ok(value.toString())), equals(Ok<String, String>('1')));
			expect(bar.andThen((value) => Ok(value.toString())), equals(Err<String, String>('bar')));
		});

		test('Should return expected values from Result#or()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.or(Ok<int, String>(2)), equals(Ok<int, String>(1)));
			expect(bar.or(Ok<int, String>(2)), equals(Ok<int, String>(2)));

			expect(foo.or(Err(2)), equals(Ok<int, int>(1)));
			expect(bar.or(Err(2)), equals(Err<int, int>(2)));
		});

		test('Should return expected values from Result#orElse()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.orElse((value) => Err('$value baz')), equals(Ok<int, String>(1)));
			expect(bar.orElse((value) => Err('$value baz')), equals(Err<int, String>('bar baz')));

			expect(foo.orElse((_) => Err(2)), equals(Ok<int, int>(1)));
			expect(bar.orElse((_) => Err(2)), equals(Err<int, int>(2)));
		});

		test('Should execute the given function and return self as expected in Result#inspect()', () {
			bool called = false;

			void inspectFn(_) {
				called = true;
			}

			Result<int, String> foo = Ok(1);

			int bar = foo.inspect(inspectFn).unwrap();

			expect(bar, equals(1));
			expect(called, equals(true));
		});

		test('Should execute the given function and return self as expected in Result#inspectErr()', () {
			bool called = false;

			void inspectFn(_) {
				called = true;
			}

			Result<int, String> foo = Err('foo');

			String bar = foo.inspectErr(inspectFn).unwrapErr();

			expect(bar, equals('foo'));
			expect(called, equals(true));
		});

		test('Should return expected values from Result#map()', () {
			Result<int, String> foo = Ok(5);

			expect(foo.map((value) => value * 10), equals(Ok<int, String>(50)));
			expect(foo.map((value) => value.toString()), equals(Ok<String, String>('5')));

			expect(foo.map((value) => [value]), equals(TypeMatcher<Ok<List<int>, String>>()));

			// Check the wrapped List directly because two Results holding
			// different references to visibly identical lists aren't equatable
			expect(foo.map((value) => [value]).unwrap(), equals([5]));

			Result<int, String> bar = Err('bar');

			expect(bar.map((value) => value.toString()), equals(Err<String, String>('bar')));
		});

		test('Should return expected values from Result#mapOr()', () {
			Result<int, String> a = Ok(1);
			Result<int, String> b = Err('foo');

			expect(a.mapOr(5, (val) => val + 1), equals(Ok<int, String>(2)));
			expect(b.mapOr(5, (val) => val + 1), equals(Ok<int, String>(5)));
		});

		test('Should return expected values from Result#mapOrElse()', () {
			Result<int, String> a = Ok(1);
			Result<int, String> b = Err('foo');

			expect(a.mapOrElse(() => 5, (val) => val + 1), equals(Ok<int, String>(2)));
			expect(b.mapOrElse(() => 5, (val) => val + 1), equals(Ok<int, String>(5)));
		});

		test('Should return expected values from Result#mapErr()', () {
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

			Result<Result<int, String>, String> baz = Err('baz');

			expect(baz.flatten(), equals(Err<int, String>('baz')));
		});

		test('Should return expected values from Result#ok()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.ok(), equals(Some(1)));
			expect(bar.ok(), equals(None<int>()));
		});

		test('Should return expected values from Result#err()', () {
			Result<int, String> foo = Ok(1);
			Result<int, String> bar = Err('bar');

			expect(foo.err(), equals(None<String>()));
			expect(bar.err(), equals(Some('bar')));
		});

		test('Should return expected values from Result#transpose()', () {
			Result<Option<int>, String> foo = Ok(Some(1));
			Result<Option<int>, String> bar = Ok(None());
			Result<Option<int>, String> baz = Err('baz');

			expect(foo.transpose(), equals(Some<Result<int, String>>(Ok(1))));
			expect(bar.transpose(), equals(None<Result<int, String>>()));
			expect(baz.transpose(), equals(Some<Result<int, String>>(Err('baz'))));
		});
	});

	group('ResultError:', () {
		test('Should return expected values from ResultError#toString()', () {
			ResultError foo = ResultError(null);
			ResultError bar = ResultError('bar');

			expect(foo.toString(), equals('ResultError'));
			expect(bar.toString(), equals('ResultError: bar'));
		});
	});
}
