import 'dart:async';

class InMemoryStore<T> {
  InMemoryStore(T initial) : _value = initial, _controller = StreamController<T>.broadcast() {
    _stream = Stream<T>.multi((multi) {
      multi.add(_value);
      final sub = _controller.stream.listen(multi.add, onError: multi.addError, onDone: multi.close);
      multi.onCancel = () => sub.cancel();
    }, isBroadcast: true);
  }

  final StreamController<T> _controller;
  late final Stream<T> _stream;
  T _value;

  Stream<T> get stream => _stream;

  T get value => _value;

  set value(T newValue) {
    if (!_controller.isClosed) {
      _value = newValue;
      _controller.add(newValue);
    }
  }

  void close() => _controller.close();
}
