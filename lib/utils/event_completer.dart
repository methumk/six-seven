import 'dart:async';

class EventCompleter {
  Completer<void>? _completer;

  EventCompleter();

  void init() {
    _completer = Completer<void>();
  }

  Future<void> wait() async {
    if (_completer == null) return;
    await _completer!.future;
  }

  void resolve() {
    if (_completer == null) return;
    _completer?.complete();
    _completer = null;
  }
}
