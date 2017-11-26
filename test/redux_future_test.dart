import 'dart:async';

import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'package:redux_future/redux_future.dart';

main() {
  group('Future Middleware', () {
    String futureReducer(String state, action) {
      if (action is String) {
        return action;
      } else if (action is FutureFulfilledAction<String>) {
        return action.result;
      } else if (action is FutureRejectedAction<Exception>) {
        return action.error.toString();
      } else {
        return state;
      }
    }

    test('is a Redux Middleware', () {
      expect(futureMiddleware, new isInstanceOf<Middleware>());
    });

    group('FutureAction', () {
      test('can synchronously dispatch an initial action', () {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final action = new FutureAction(
          new Future.value("Fetch Complete"),
          initialAction: "Fetching",
        );

        store.dispatch(action);

        expect(store.state, action.initialAction);
      });

      test(
          'dispatches a FutureFulfilledAction if the future completes successfully',
          () async {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final dispatchedAction = "Friend";
        final future = new Future.value(dispatchedAction);
        final action = new FutureAction(
          future,
          initialAction: "Hi",
        );

        store.dispatch(action);

        await future;

        expect(store.state, dispatchedAction);
      });

      test('dispatches a FutureRejectedAction if the future returns an error',
          () {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final exception = new Exception("Error Message");
        final future = new Future.error(exception);
        final action = new FutureAction(
          future,
          initialAction: "Hi",
        );

        store.dispatch(action);

        expect(
          future.catchError((_) => store.state),
          completion(contains(exception.toString())),
        );
      });

      test('returns the result of the Future after it has been dispatched',
          () async {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final dispatchedAction = "Friend";
        final future = new Future.value(dispatchedAction);
        final action = new FutureAction(
          future,
          initialAction: "Hi",
        );

        store.dispatch(action);

        expect(
          await action.result,
          new FutureFulfilledAction(dispatchedAction),
        );
      });

      test('returns the error of the Future after it has been dispatched',
          () async {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final exception = new Exception("Khaaaaaaaaaan");
        final future = new Future.error(exception);
        final action = new FutureAction(
          future,
          initialAction: "Hi",
        );

        store.dispatch(action);

        expect(
          await action.result,
          new FutureRejectedAction(exception),
        );
      });
    });

    group('Future', () {
      test(
          'dispatches a FutureFulfilledAction if the future completes successfully',
          () async {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final dispatchedAction = "Friend";
        final future = new Future.value(dispatchedAction);

        store.dispatch(future);

        await future;

        expect(store.state, dispatchedAction);
      });

      test('dispatches a FutureRejectedAction if the future returns an error',
          () {
        final store = new Store<String>(
          futureReducer,
          middleware: [futureMiddleware],
        );
        final exception = new Exception("Error Message");
        final future = new Future.error(exception);

        store.dispatch(future);

        expect(
          future.catchError((_) => store.state),
          completion(contains(exception.toString())),
        );
      });
    });
  });
}
