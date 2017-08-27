library redux_future;

import 'dart:async';
import 'package:redux/redux.dart';

/// If you'd like to dispatch the result of a [Future] to your Redux [Store],
/// without needing access to the [Store.dispatch] method directly in a Widget,
/// you can attach the [futureMiddleware] to your [Store] and dispatch a
/// simple [Future], or [FutureAction] that contains your [Future] inside.
///
/// The [Future] or [FutureAction] will be intercepted by the middleware. If the
/// future completes successfully, a [FutureFulfilledAction] will be dispatched
/// with the result of the future. If the future fails, a [FutureRejectedAction]
/// will be dispatched containing the error that was returned.
///
/// ### Examples
///
///     // First, create a reducer that knows how to handle the FutureActions:
///     // `FutureFulfilledAction` and `FutureRejectedAction`.
///     String exampleReducer(String state, action) {
///       if (action is String) {
///         return action;
///       } else if (action is FutureFulfilledAction<String>) {
///         return action.result;
///       } else if (action is FutureRejectedAction<Exception>) {
///         return action.error.toString();
///       }
///
///       return state;
///     }
///
///     // Next, create a Store that includes `futureMiddleware`. It will
///     // intercept all `Future`s or `FutureAction`s that are dispatched.
///     final store = new Store(
///       exampleReducer,
///       middleware: [futureMiddleware],
///     );
///
///     // In this example, once the Future completes, a `FutureFulfilledAction`
///     // will be dispatched with "Hi" as the result. The `exampleReducer` will
///     // take the result of this action and update the state of the Store!
///     store.dispatch(new Future(() => "Hi"));
///
///     // In this example, the initialAction String "Fetching" will be
///     // immediately dispatched. After the future completes, the
///     // "Search Results" will be dispatched.
///     store.dispatch(new FutureAction(
///       new Future(() => "Search Results"),
///       initialAction: "Fetching"));
///
///     // In this example, the future will complete with an error. When that
///     // happens, a `FutureRejectedAction` will be dispatched to your store,
///     // and the state will be updated by the `exampleReducer`.
///     store.dispatch(new Future.error("Oh no!"));
void futureMiddleware<State>(Store<State> store, action, NextDispatcher next) {
  if (action is FutureAction) {
    if (action.initialAction != null) {
      next(action.initialAction);
    }

    _dispatchResults(store, action.future);
  } else if (action is Future) {
    _dispatchResults(store, action);
  } else {
    next(action);
  }
}

// Dispatches the result of a future to the Store.
void _dispatchResults<State>(Store<State> store, Future<dynamic> future) {
  future
      .then((result) => store.dispatch(new FutureFulfilledAction(result)))
      .catchError((error) => store.dispatch(new FutureRejectedAction(error)));
}

/// If you'd like to dispatch the result of a [Future] to your Redux [Store],
/// without needing access to the [Store.dispatch] method directly, you can
/// attach the [futureMiddleware] to your [Store] and dispatch a `FutureAction`.
///
/// The FutureAction will be intercepted by the [futureMiddleware]. If the
/// future completes successfully, a [FutureFulfilledAction] will be dispatched
/// with the result of the future. If the future fails, a [FutureRejectedAction]
/// will be dispatched containing the error that was returned.
///
/// ### Examples
///
///     // In this example, once the Future completes, a `FutureFulfilledAction`
///     // will be dispatched with "Hi" as the result.
///     store.dispatch(new FutureAction(new Future(() => "Hi")));
///
///     // In this example, the future will complete with an error. When that
///     // happens, a `FutureRejectedAction` will be dispatched with an
///     // `new Exception("Oh no!")` contained within.
///     store.dispatch(new FutureAction(new Future.error(
///         new Exception("Oh no!"))));
class FutureAction<T> {
  /// The [Future] that will be awaited. If it completes successfully, a
  /// [FutureFulfilledAction] will be dispatched with the result. If the future
  /// fails, a [FutureRejectedAction] will be dispatched containing the error
  /// that was returned.
  final Future<T> future;

  /// Optional: If an initialAction is provided, it will be dispatched
  /// immediately, before any actions from the [future] are returned.
  final dynamic initialAction;

  FutureAction(
    this.future, {
    this.initialAction,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FutureAction &&
          runtimeType == other.runtimeType &&
          initialAction == other.initialAction &&
          future == other.future;

  @override
  int get hashCode => initialAction.hashCode ^ future.hashCode;

  @override
  String toString() {
    return 'AsyncAction{initialAction: $initialAction, future: $future}';
  }
}

/// This action will be dispatched if the [Future] provided to a [FutureAction]
/// completes successfully.
class FutureFulfilledAction<T> {
  final T result;

  FutureFulfilledAction(this.result);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FutureFulfilledAction &&
          runtimeType == other.runtimeType &&
          result == other.result;

  @override
  int get hashCode => result.hashCode;

  @override
  String toString() {
    return 'FutureFulfilledAction{result: $result}';
  }
}

/// This action will be dispatched if the [Future] provided to a [FutureAction]
/// finishes with an error.
class FutureRejectedAction<E> {
  final E error;

  FutureRejectedAction(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FutureRejectedAction &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() {
    return 'FutureRejectedAction{error: $error}';
  }
}
