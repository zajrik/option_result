import 'package:test/test.dart';
import 'package:option_result/option.dart';

void main() {
	group('Option:', () {
		test('Should hold and unwrap simple values', () {
			expect(Some('foo bar baz').unwrap(), equals('foo bar baz'));
			expect(Some(42).unwrap(), equals(42));
			expect(Some(false).unwrap(), equals(false));
		});

		test('Should hold and unwrap complex values', () {
			expect(Some({'foo': 'bar', 'baz': 42}).unwrap(), equals({'foo': 'bar', 'baz': 42}));
			expect(Some(['foo', 'bar', 'baz']).unwrap(), equals(['foo', 'bar', 'baz']));
		});

		test('Should equate equatable Options', () {
			expect(Some('foo') == Some('foo'), equals(true));
			expect(None() == None(), equals(true));

			Map<String, dynamic> foo = {'foo': 'bar', 'baz': 42};

			// They share the same reference to foo
			expect(Some(foo) == Some(foo), equals(true));
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

		test('Should return expected values from Option#isSome()', () {
			expect(Some(null).isSome(), equals(true));
			expect(None().isSome(), equals(false));
		});

		test('Should return expected values from Option#isSomeAnd()', () {
			expect(Some(1).isSomeAnd((value) => value == 1), equals(true));
			expect(Some(1).isSomeAnd((value) => value >= 2), equals(false));
			expect(None().isSomeAnd((_) => true), equals(false));
		});

		test('Should return expected values from Option#isNone()', () {
			expect(Some(null).isNone(), equals(false));
			expect(None().isNone(), equals(true));
		});

		test('Should return expected values from Option#unwrapOr()', () {
			expect(Some(1).unwrapOr(2), equals(1));
			expect(None().unwrapOr(2), equals(2));
		});

		test('Should create expected Options via Option.from()', () {
			expect(Option.from('foo'), equals(Some('foo')));
			expect(Option<int>.from(null), equals(None<int>()));
		});

		test('Should return expected values from Option#expect()', () {
			expect(Some(1).expect('should be Some()'), equals(1));
			expect(() => None().expect('Should be Some()'), throwsA(TypeMatcher<OptionError>()));
		});

		test('Should return expected values from Option#and()', () {
			Option<int> foo = Some(1);
			Option<int> bar = None();

			expect(foo.and(Some(2)), equals(Some(2)));
			expect(bar.and(Some(2)), equals(None<int>()));

			expect(foo.and(Some('foo')), equals(Some('foo')));
			expect(bar.and(Some('foo')), equals(None<String>()));
		});

		test('Should return expected values from Option#andThen()', () {
			Option<int> foo = Some(1);
			Option<int> bar = None();

			expect(foo.andThen((value) => Some(value * 2)), equals(Some(2)));
			expect(bar.andThen((value) => Some(value * 2)), equals(None<int>()));

			expect(foo.andThen((value) => Some(value.toString())), equals(Some('1')));
			expect(bar.andThen((value) => Some(value.toString())), equals(None<String>()));
		});

		test('Should return expected values from Option#or()', () {
			Option<int> foo = None();
			Option<int> bar = Some(1);
			Option<int> baz = None();

			expect(foo.or(bar), equals(Some(1)));
			expect(bar.or(Some(2)), equals(Some(1)));
			expect(foo.or(baz), equals(None<int>()));
		});

		test('Should return expected values from Option#orElse()', () {
			Option<int> foo = None();
			Option<int> bar = Some(1);
			Option<int> baz = None();

			expect(foo.orElse(() => Some(2)), equals(Some(2)));
			expect(bar.orElse(() => Some(2)), equals(Some(1)));
			expect(baz.orElse(() => None()), equals(None<int>()));
		});

		test('Should return expected values from Option#xor()', () {
			Option<int> a = Some(1);
			Option<int> b = None();
			Option<int> c = Some(2);

			expect(a.xor(b), equals(Some(1)));
			expect(b.xor(c), equals(Some(2)));
			expect(a.xor(c), equals(None<int>()));
			expect(b.xor(b), equals(None<int>()));
		});

		test('Should execute the given function and return self as expected in Option#inspect()', () {
			bool called = false;

			void inspectFn(int value) {
				called = true;
			}

			Option<int> foo = Some(1);

			int bar = foo.inspect(inspectFn).unwrap();

			expect(bar, equals(1));
			expect(called, equals(true));
		});

		test('Should return expected values from Option#filter()', () {
			Option<int> foo = Some(5);

			expect(foo.filter((value) => value < 10), equals(Some(5)));
			expect(foo.filter((value) => value > 6), equals(None<int>()));
		});

		test('Should return expected values from Option#map()', () {
			Option<int> foo = Some(5);

			expect(foo.map((value) => value * 10), equals(Some(50)));
			expect(foo.map((value) => value.toString()), equals(Some('5')));

			expect(foo.map((value) => [value]), equals(TypeMatcher<Some<List<int>>>()));

			// Check the wrapped List directly because two Options holding
			// different references to visibly identical lists aren't equatable
			expect(foo.map((value) => [value]).unwrap(), equals([5]));
		});

		test('Should return expected values from Option#mapOr()', () {
			Option<int> a = Some(1);
			Option<int> b = None();

			expect(a.mapOr(5, (val) => val + 1), equals(Some(2)));
			expect(b.mapOr(5, (val) => val + 1), equals(Some(5)));
		});

		test('Should return expected values from Option#mapOrElse()', () {
			Option<int> a = Some(1);
			Option<int> b = None();

			expect(a.mapOrElse(() => 5, (val) => val + 1), equals(Some(2)));
			expect(b.mapOrElse(() => 5, (val) => val + 1), equals(Some(5)));
		});

		test('Should return expected values from Option#zip()', () {
			Option<(int, String)> zipped = Some(1).zip(Some('foo'));

			expect(zipped, equals(Some((1, 'foo'))));
			expect(Some(1).zip(None<int>()), equals(None<(int, int)>()));
		});

		test('Should return expected values from Option#zipWith()', () {
			Option<int> x = Some(1);
			Option<int> y = Some(2);

			expect(x.zipWith(y, Point.new), equals(Some(Point(1, 2))));
		});

		test('Should return expected values from Option#unzip()', () {
			Option<(int, String)> zipped = Some((1, 'foo'));

			expect(zipped.unzip(), equals((Some(1), Some('foo'))));
			expect(None<(int, int)>().unzip(), equals((None<int>(), None<int>())));

			// Test implicit and explicit typing on unzip()
			Option<(int, int)> foo = None();
			(Option<int>, Option<int>) bar = foo.unzip();
			var baz = foo.unzip();

			expect(bar, equals((None<int>(), None<int>())));
			expect(baz, equals((None<int>(), None<int>())));
		});

		test('Should return expected values from Option#flatten()', () {
			Option<Option<Option<Option<int>>>> foo = Some(Some(Some(Some(1))));

			// Option.from() here because it won't equate Some<Some<T>> to Option<Option<T>>
			// but Option<Option<T>> compares fine. I assumed it was from the runtimeType
			// comparison in == but removing that still doesn't allow equals() to consider
			// the values the same here despite that fixing == for these cases.
			expect(foo.flatten(), equals(Option.from(Option.from(Option.from(1)))));
			expect(foo.flatten().flatten(), equals(Option.from(Option.from(1))));
			expect(foo.flatten().flatten().flatten(), equals(Option.from(1)));

			// 4 flatten()s won't compile because it's no longer Option<Option<int>> after 3
			// expect(foo.flatten().flatten().flatten().flatten(), equals(Some(1)));
		});
	});
}

class Point {
	int x;
	int y;

	Point(this.x, this.y);

	@override
	operator ==(Object other) => switch (other) {
		Point(x: int otherX, y: int otherY) => x == otherX && y == otherY,
		_ => false
	};

	@override
	int get hashCode => Object.hash(x, y);
}
