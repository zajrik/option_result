## 2.2.0

- Un-deprecate `~` operator for `Result<(), E>` type values
  - This keeps the ergonomics of `~` for unwrapping awaited Results, but only where
    the value would be discarded anyway, i.e., unwrapping a result that is only used
    for error handling inside a `catchResult` or `catchResultAsync` block so that the
    error can propagate.

## 2.1.0

- Add `Option.call()` to allow calling `Option` values like a function to unwrap
  their held values.
- Add `Result.call()` to allow calling `Result` values like a function to unwrap
  their held values.

### Deprecation

- Deprecated `~` operators for `Option` and `Result` types.
  - Use `Option/Result.call()` as `value()` to unwrap with minimal syntax instead.
    - This prevents the need for accommodating operator precedence when unwrapping
      `Option`/`Result` values which provides a more ergonomic experience when accessing
      values/methods on the unwrapped value is needed.

## 2.0.1

- Remove work-in-progress message from readme.
  - How did I miss this?
    - help

## 2.0.0

### Breaking changes

- Remove `~` shortcut for Option/Result propagation.
  - I failed to test the most obvious use-case. Due to the lack of generics on operators,
  when both variants of `Option` or `Result` are returned in the same prefixed function,
  the return type is inferred by the compiler to be `Object` and the propagation
  extensions then fail to recognize the function as a valid target for the `~` operator.

    To compensate, I made the Option/Result propagation helpers easier to type by
  renaming them, saving 4 characters and 2 syllables. It's the best I can think of
  until such time that Dart supposed fully generic operator definitions.
- Rename `propagateOption()` -> `catchOption()`.
- Rename `propagateResult()` -> `catchResult()`.
- Rename `propagateOptionAsync()` -> `catchOptionAsync()`.
- Rename `propagateResultAsync()` -> `catchResultAsync()`.

## 1.0.0

- Final documentation update for 1.0.0 release. 🎉

## 0.1.0-dev-4

- Update documentation.

## 0.1.0-dev-3

- Allow `const` `Option` and `Result` values.
- Rename `Option#filter()` -> `Option#where()`.
  - This is more Dart-idiomatic.

## 0.1.0-dev-2

- Add `Option#iter()`.
- Add `Result#iter()`.

## 0.1.0-dev-1

- Add `Option#toString()`.
- Add `Result#toString()`.
- Rework `==` for `Option` and `Result` types.
  - Previously `==` would check for matching runtime types in addition to held value equality.
  I was trying to keep things as close to Rust's behavior as I could. It didn't occur to me
  until after I rewrote it to be more accommodating of `dynamic` values that it didn't support
  comparing held values that inherit from eachother that might normally be comparable in both
  the original implementation and the rewrite so I scrapped both in favor of solely comparing
  held values.

## 0.0.1-dev-9

- Add `Result#transpose()`, `ok()`, `err()`.

## 0.0.1-dev-8

- Add `Option#unwrapOrElse()`, `okOr()`, `okOrElse()`, `transpose()`.
- Add `Result#unwrapOrElse()`, `isOkAnd()`, `isErrAnd()`, `mapOr()`, `mapOrElse()`.

## 0.0.1-dev-7

- Add `Option#inspect()`, `xor()`, `isSomeAnd()`, `mapOr()`, `mapOrElse()`.
- Add `Result#inspect()`, `inspectErr()`.

## 0.0.1-dev-6

- Add `Option#flatten()`.
- Add `Result#flatten()`.
- Refactor `~` shortcut for `propagateResult/Async` to return dynamic for ergonomics.
  - See documentation for more information.

## 0.0.1-dev-5

- Add `~` operator for unwrapping `Option` and `Result` types.
- Add `~` operator as shortcut for propagating `None()`/`Err()` in functions returning `Option`/`Result`.
- Rework `Option#unzip()` via extension methods to only provide the method on `Option<(T, U)>` values.

## 0.0.1-dev-4

- Add `Option#and()`, `andThen()`, `or()`, `orElse()`, `expect()`.
- Add `Result#and()`, `andThen()`, `or()`, `orElse()`, `expect()`, `expectErr()`.

## 0.0.1-dev-3

- Add `Option#map()`, `zip()`, `zipWith()`, `unzip()`.
- Add `Result#map()`, `mapErr()`.
- Reworked `propagateResult/Async` semantics to be more in-line with Rust's `Result` `Err` propagation.

## 0.0.1-dev-2

- Add separate packages to allow importing `option` and `result` separately.
- Add `Option#filter()` method.

## 0.0.1-dev-1

- Initial version.
