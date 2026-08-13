import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Base for GetX application controllers that publish grouped domain changes.
abstract class ReactiveController extends GetxController {
  final RxInt _revision = 0.obs;

  /// Observes grouped controller changes without exposing mutable Rx state.
  Worker watch(VoidCallback listener) =>
      ever<int>(_revision, (_) => listener());

  @protected
  void refreshState() {
    _revision.value++;
    update();
  }
}
