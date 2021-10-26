import 'dart:io';
import 'dart:async';

typedef StdinObserver = void Function(List<int> event);

/// stdin stream manager
/// Use this class to handle stdin data instead of listen `stdin` stream directly
class StdinManager {
  factory StdinManager() => _instance;

  // ignore: unused_element
  StdinManager._() {
    _streamSubscription = stdin.listen((event) {
      _dispatch(event);
    });
  }

  /// StdinManager single instance
  static final StdinManager _instance = StdinManager();

  /// stdin raw stream's subscription
  StreamSubscription<List<int>>? _streamSubscription;

  /// stdin observer list
  List<StdinObserver>? _stdinObserver;

  /// Insert stdin observer, the new one will grab data stream
  /// for own use, until next observer come or close by itself
  StdinSubscription insertObserver(StdinObserver observer) {
    _stdinObserver ??= [];
    _stdinObserver!.insert(0, observer);
    return StdinSubscription._(observer);
  }

  /// Close stdin stream
  void close() {
    _streamSubscription!.cancel();
  }

  /// Dispatch `stdin` event to observer
  void _dispatch(List<int> event) {
    _stdinObserver?.first.call(event);
  }

  /// Cancel stdin observer
  void _cancelObserver(StdinObserver observer) {
    _stdinObserver?.remove(observer);
    if (_stdinObserver != null && _stdinObserver!.isEmpty) {
      _stdinObserver = null;
    }
  }
}

/// stdin observer subscription
/// Use for cancel observer this wrapped
class StdinSubscription {
  StdinSubscription._(this.observer);

  ///
  final StdinObserver observer;

  /// Cancel observer
  void cancel() {
    StdinManager()._cancelObserver(observer);
  }
}
