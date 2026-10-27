import 'package:flutter/material.dart';

import '../errors/error_mapper.dart';
import '../widgets/app_toast.dart';

extension ContextX on BuildContext {
  void showMessage(String message, {bool isError = false}) => AppToast.show(
    this,
    message,
    type: isError ? ToastType.error : ToastType.success,
  );

  void showError(Object error) =>
      showMessage(friendlyError(error), isError: true);

  void unfocus() => FocusScope.of(this).unfocus();
}
