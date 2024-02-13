import 'dart:async';

class AsyncOperation {
  static final Completer _completer = Completer();

  static Future doOperation<T>(Function startOperation) {
    startOperation();
    return _completer.future; // Send future object back to client.
  }

  // Something calls this when the value is ready.
  static void finishOperation<T>(T result) {
    _completer.complete(result);
  }

  // If something goes wrong, call this.
  static void errorHappened<T>(Object error) {
    _completer.completeError(error);
  }
}
