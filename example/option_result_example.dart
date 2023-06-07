import 'package:option_result/option_result.dart';

void main() {
	Option<int> foo = Some(1);
	Option<int> bar = None();

	Option<int> add(Option<int> a, Option<int> b) => propagateOption(() {
		return Some(a.unwrap() + b.unwrap());
	});

	Option<int> baz = add(foo, bar);

	print(switch (baz) {
		Some(value: int value) => 'Value is $value',
		None() => 'There is no value!'
	});

	Result<int, String> foo2 = Ok(1);
	Result<int, String> bar2 = Err('Oop!');

	Result<int, String> add2(Result<int, String> a, Result<int, String> b) => propagateResult(() {
		return Ok(a.unwrap() + b.unwrap());
	});

	Result<int, String> baz2 = add2(foo2, bar2);

	print(switch (baz2) {
		Ok(value: int value) => 'Value is $value',
		Err(value: String err) => 'Error: $err'
	});
}
