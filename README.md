# redux_future

[![build status](https://gitlab.com/brianegan/redux_future/badges/master/build.svg)](https://gitlab.com/brianegan/redux_future/commits/master)  [![coverage report](https://gitlab.com/brianegan/redux_future/badges/master/coverage.svg)](https://brianegan.gitlab.io/redux_future/coverage/)

A [Redux](https://pub.dartlang.org/packages/redux) Middleware for handling Dart Futures as actions. 

If you'd like to dispatch the result of a `Future` to your Redux `Store`, without needing access to the `Store.dispatch` method directly in part of your application, such as a Flutter widget, you can attach the `futureMiddleware` to your `Store` and dispatch either a `Future` directly or a `FutureAction`, which contains your `Future` inside, as well as an optional initial action to be dispatched.
 
The `Future` or `FutureAction` will be intercepted by the `futureMiddleware`. If the future completes successfully, a `FutureFulfilledAction` will be dispatched with the result of the future. If the future fails, a `FutureRejectedAction` will be dispatched containing the error that was returned.

### Examples

```dart
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
store.dispatch(new Future(() => "Hi"));

// In this example, the initialAction String "Fetching" will be
// immediately dispatched. After the future completes, the
// "Search Results" will be dispatched.
store.dispatch(new FutureAction(
  new Future(() => "Search Results"),
  initialAction: "Fetching"));

// In this example, the future will complete with an error. When that
// happens, a `FutureRejectedAction` will be dispatched to your store,
// and the state will be updated by the `exampleReducer`.
store.dispatch(new Future.error("Oh no!"));
```
