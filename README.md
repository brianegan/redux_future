# redux_future

[![Build Status](https://travis-ci.org/brianegan/redux_future.svg?branch=master)](https://travis-ci.org/brianegan/redux_future) [![codecov](https://codecov.io/gh/brianegan/redux_future/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/redux_future)

A [Redux](https://pub.dartlang.org/packages/redux) Middleware for handling Dart Futures as actions, with support for loading & optimistic payloads. 

The `futureMiddleware` can be attached to the Redux `Store` upon construction. 

Once attached, you can `store.dispatch` a `Future` or [`FutureAction`](https://www.dartdocs.org/documentation/redux_future/latest/redux_future/FutureAction-class.html), and the `futureMiddleware` will intercept it. 

  * If the `Future` / `FutureAction` completes successfully, a `FutureFulfilledAction` will be dispatched with the result of the future. 
  * If the `Future` / `FutureAction` fails, a `FutureRejectedAction` will be dispatched containing the error that was returned.

### Examples

```dart

main() {
  // First, create a reducer that knows how to handle the Future Actions:
  // `FutureFulfilledAction` and `FutureRejectedAction`.
  String exampleReducer(String state, action) {
    if (action is String) {
      return action;
    } else if (action is FutureFulfilledAction<String>) {
      return action.result;
    } else if (action is FutureRejectedAction<Exception>) {
      return action.error.toString();
    }
  
    return state;
  }
  
  // Next, create a Store that includes `futureMiddleware`. It will
  // intercept all `FutureAction`s that are dispatched.
  final store = new Store(
    exampleReducer,
    middleware: [futureMiddleware],
  );
  
  // Next, dispatch some actions!
  
  // In this example, once the Future completes, a `FutureFulfilledAction`
  // will be dispatched with "Hi" as the result. The `exampleReducer` will
  // take the result of this action and update the state of the Store!
  store.dispatch(new Future.value("Hi"));
  
  // In this example, the initialAction String "Fetching" will be
  // immediately dispatched. After the future completes, the
  // "Search Results" will be dispatched.
  store.dispatch(new FutureAction(
    new Future.value("Search Results"),
    initialAction: "Fetching"));
  
  // In this example, the future will complete with an error. When that
  // happens, a `FutureRejectedAction` will be dispatched to your store,
  // and the state will be updated by the `exampleReducer`.
  store.dispatch(new Future.error("Oh no!"));
}
```

## Contributors

  * [Brian Egan](http://github.com/brianegan)
  * [Kezhu Wang](https://github.com/kezhuw)
