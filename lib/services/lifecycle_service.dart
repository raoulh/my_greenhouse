import 'dart:async';

import 'package:flutter/widgets.dart';

typedef FutureVoidCallback = FutureOr<void> Function();

class LifeCycleService extends WidgetsBindingObserver with ChangeNotifier {
  final FutureVoidCallback? onResume;
  final FutureVoidCallback? onSuspend;

  late AppLifecycleState _lastState;
  bool hasResumed = false;

  LifeCycleService({
    this.onResume,
    this.onSuspend,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused) {
      //await onResume!();
      for (final FutureVoidCallback observer in _resumeObservers) {
        observer();
      }
      hasResumed = true;
    } else if (state == AppLifecycleState.detached) {
      //await onSuspend!();
      for (final FutureVoidCallback observer in _suspendObservers) {
        observer();
      }
      hasResumed = false;
    }

    _lastState = state;
  }

  void resetResumedState() {
    hasResumed = false;
  }

  final List<FutureVoidCallback> _resumeObservers = <FutureVoidCallback>[];
  final List<FutureVoidCallback> _suspendObservers = <FutureVoidCallback>[];

  void addResumeObserver(FutureVoidCallback observer) =>
      _resumeObservers.add(observer);
  void addSuspendObserver(FutureVoidCallback observer) =>
      _suspendObservers.add(observer);
  bool removeResumeObserver(FutureVoidCallback observer) =>
      _resumeObservers.remove(observer);
  bool removeSuspendObserver(FutureVoidCallback observer) =>
      _suspendObservers.remove(observer);
}
