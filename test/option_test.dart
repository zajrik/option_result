import 'package:test/test.dart';
import 'package:option_result/option.dart';

void main() {
	group('Option:', () {
		test('Should return expected values for isSome()/isNone()', () {
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

		test('Should return expected values from unwrapOr()', () {
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

		test('Should not equate Options with equatable values but mismatched types', () {
			Option<int> foo = Some(1);
			Option<num> bar = Some(1);

			expect(foo == bar, equals(false));

			Option<int> foo2 = None();
			Option<bool> bar2 = None();

			// ignore: unrelated_type_equality_checks
			expect(foo2 == bar2, equals(false));
		});

		test('Should create expected Options via Option.from()', () {
			expect(Option.from('foo'), equals(Some('foo')));
			expect(Option<int>.from(null), equals(None<int>()));
		});

		test('Should throw OptionError when unwrapping None()', () {
			expect(() => None().unwrap(), throwsA(TypeMatcher<OptionError>()));
		});

		test('Should return expected values from Option#expect()', () {
			expect(Some(1).expect('should be Some()'), equals(1));
			expect(() => None().expect('Should be Some()'), throwsA(TypeMatcher<OptionError>()));
		});

		test('Should return expected values for Option#and()', () {
			Option<int> foo = Some(1);
			Option<int> bar = None();

			expect(foo.and(Some(2)), equals(Some(2)));
			expect(bar.and(Some(2)), equals(None<int>()));

			expect(foo.and(Some('foo')), equals(Some('foo')));
			expect(bar.and(Some('foo')), equals(None<String>()));
		});

		test('Should return expected values for Option#andThen()', () {
			Option<int> foo = Some(1);
			Option<int> bar = None();

			expect(foo.andThen((value) => Some(value * 2)), equals(Some(2)));
			expect(bar.andThen((value) => Some(value * 2)), equals(None<int>()));

			expect(foo.andThen((value) => Some(value.toString())), equals(Some('1')));
			expect(bar.andThen((value) => Some(value.toString())), equals(None<String>()));
		});

		test('Should return expected values for Option#or()', () {
			Option<int> foo = None();
			Option<int> bar = Some(1);
			Option<int> baz = None();

			expect(foo.or(bar), equals(Some(1)));
			expect(bar.or(Some(2)), equals(Some(1)));
			expect(foo.or(baz), equals(None<int>()));
		});

		test('Should return expected values for Option#orElse()', () {
			Option<int> foo = None();
			Option<int> bar = Some(1);
			Option<int> baz = None();

			expect(foo.orElse(() => Some(2)), equals(Some(2)));
			expect(bar.orElse(() => Some(2)), equals(Some(1)));
			expect(baz.orElse(() => None()), equals(None<int>()));
		});

		test('Should return expected values for Option#filter()', () {
			Option<int> foo = Some(5);

			expect(foo.filter((value) => value < 10), equals(Some(5)));
			expect(foo.filter((value) => value > 6), equals(None<int>()));
		});

		test('Should return expected values for Option#map()', () {
			Option<int> foo = Some(5);

			expect(foo.map((value) => value * 10), equals(Some(50)));
			expect(foo.map((value) => value.toString()), equals(Some('5')));

			expect(foo.map((value) => [value]), equals(TypeMatcher<Some<List<int>>>()));

			// Check the wrapped List directly because two Options holding
			// different references to visibly identical lists aren't equatable
			expect(foo.map((value) => [value]).unwrap(), equals([5]));
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
