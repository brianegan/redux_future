# Changelog

## 0.1.3

  - Dispatch `initialAction` through the entire Middelware chain. Fix contributed by [Kezhu Wang](https://github.com/kezhuw)!

## 0.1.2

  - Fix `FutureAction` incorrect type parameter. Fix contributed by [Kezhu Wang](https://github.com/kezhuw)!

## 0.1.1

  - Move to Github
  - Add the ability to await the resulting action (Fulfilled or Rejected) after it has been dispatched to the store.
  - Added `FutureResultAction` as base class for Fulfilled / Rejected actions.

## 0.1.0

  - Initial version, includes a `futureMiddleware` that intercepts Futures and FutureActions, captures their results, and dispatches their results as Redux actions.
  - Included classes
    - `FutureAction`
    - `FutureFulfilledAction`
    - `FutureRejectedAction`
