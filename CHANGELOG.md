## 0.0.1-dev-6

- Add `Option#flatten()`
- Add `Result#flatten()`
- Refactor `~` shortcut for `propagateResult/Async` to return dynamic for ergonomics.
  - See documentation for more information

## 0.0.1-dev-5

- Add `~` operator for unwrapping `Option` and `Result` types
- Add `~` operator as shortcut for propagating `None()`/`Err()` in functions returning `Option`/`Result`
- Rework `Option#unzip()` via extension methods to only provide the method on `Option<(T, U)>` values

## 0.0.1-dev-4

- Add `Option#and()`, `andThen()`, `or()`, `orElse()`, `expect()`
- Add `Result#and()`, `andThen()`, `or()`, `orElse()`, `expect()`, `expectErr()`

## 0.0.1-dev-3

- Add `Option#map()`, `zip()`, `zipWith()`, `unzip()`
- Add `Result#map()`, `mapErr()`
- Reworked `propagateResult/Async` semantics to be more in-line with Rust's `Result` `Err` propagation

## 0.0.1-dev-2

- Add separate packages to allow importing `option` and `result` separately
- Add `Option#filter()` method

## 0.0.1-dev-1

- Initial version.
