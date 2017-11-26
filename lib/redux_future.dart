library redux_future;

import 'dart:async';
import 'package:redux/redux.dart';

/// A Redux [Store] Middleware for handling Dart Futures as actions, with
/// support for optimistic payloads.
///
/// The `futureMiddleware` can be attached to the Redux `Store` upon
/// construction.
///
/// Once attached, you can `store.dispatch` a `Future` or `FutureAction`, and
/// the `futureMiddleware` will intercept it.
///
///   * If the `Future` / `FutureAction` completes successfully, a
///   `FutureFulfilledAction` will be dispatched with the result of the future.
///   * If the `Future` / `FutureAction` fails, a `FutureRejectedAction` will be
///   dispatched containing the error that was returned.
///
/// ### Examples
///
///     // First, create a reducer that knows how to handle the
///     // `FutureFulfilledAction` and `FutureRejectedAction` actions.
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

    _dispatchResults(store, action.future).then(action.completer.complete);
  } else if (action is Future) {
    _dispatchResults(store, action);
  } else {
    next(action);
  }
}

// Dispatches the result of a future to the Store.
Future<FutureResultAction> _dispatchResults<State>(
  Store<State> store,
  Future<FutureResultAction> future,
) {
  return future.then((result) {
    final fulfilledAction = new FutureFulfilledAction(result);
    store.dispatch(fulfilledAction);
    return fulfilledAction;
  }).catchError((error) {
    final errorAction = new FutureRejectedAction(error);
    store.dispatch(errorAction);
    return errorAction;
  });
}

/// An Action that contains a `Future`, supports loading actions / "optimistic
/// updates" by firing an [initialAction] before the Future completes, and can
/// be awaited for the final FulFilled or Rejected [result] from the Middleware.
///
///   * If the `Future` contained within the `FutureAction` completes
///   successfully, a `FutureFulfilledAction` will be dispatched with the result
///   of the future.
///   * If the `Future` contained within the `FutureAction` fails, a
///   `FutureRejectedAction` will be dispatched containing the error that was
///   returned.
///
/// In some cases, you may want to fire an action before the Future completes.
/// For example, you could fire a `SearchResultsFetching` action so your State
/// can set a `fetching` value to true, and your UI can display a loading screen
/// in response. In this case, you can use the [initialAction] parameter.
///
/// In addition, if you need to wait until the Fulfilled or Rejected action has
/// been dispatched to the Store, you can wait for the [result] `Future` to
/// complete.
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
  ///
  /// Useful for Loading Screens and "optimistic updates"
  final dynamic initialAction;

  /// Internal use only. To know when the Future has completed and the
  /// middleware has dispatched the Success or Error to the Store, use the
  /// [result] getter.
  final completer = new Completer<FutureResultAction>();

  /// Returns a [FutureFulfilledAction] or [FutureRejectedAction] action from
  /// the [futureMiddleware] after the middleware has dispatched the action
  /// to the [Store].
  Future<FutureResultAction> get result => completer.future;

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
    return 'FutureAction{future: $future, initialAction: $initialAction}';
  }
}

/// A base class for the Dispatched Actions.
abstract class FutureResultAction {}

/// This action will be dispatched if the [Future] provided to a [FutureAction]
/// completes successfully.
class FutureFulfilledAction<T> implements FutureResultAction {
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
class FutureRejectedAction<E> implements FutureResultAction {
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
