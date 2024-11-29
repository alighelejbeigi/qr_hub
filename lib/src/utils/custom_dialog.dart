import 'package:flutter/material.dart';

class CustomDialog {
  static final CustomDialog _instance = CustomDialog.internal();

  CustomDialog.internal();

  factory CustomDialog() => _instance;

  static void showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget customWidget,
    String okBtnText = 'تایید',
    String? cancelBtnText,
    VoidCallback? okBtnFunction,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: customWidget,
        actions: <Widget>[
          Row(
            children: [
              if (okBtnFunction != null)
                _okButton(okBtnFunction, okBtnText)
              else
                const SizedBox.shrink(),
              const Spacer(),
              if (cancelBtnText != null)
                _cancelButton(cancelBtnText, context)
              else
                const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _cancelButton(String cancelBtnText, BuildContext context) =>
      InkWell(
        child: DecoratedBox(
          decoration: _boxDecoration(),
          child: Padding(
            padding: _edgeInsets(),
            child: Text(
              cancelBtnText,
              style: _textStyle(),
            ),
          ),
        ),
        onTap: () => Navigator.pop(context),
      );

  static Widget _okButton(VoidCallback okBtnFunction, String okBtnText) =>
      InkWell(
        onTap: okBtnFunction,
        child: DecoratedBox(
          decoration: _boxDecoration(),
          child: Padding(
            padding: _edgeInsets(),
            child: Text(
              okBtnText,
              style: _textStyle(),
            ),
          ),
        ),
      );

  static TextStyle _textStyle() => const TextStyle(
      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);

  static EdgeInsets _edgeInsets() => const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      );

  static BoxDecoration _boxDecoration() => BoxDecoration(
        color: const Color(0xffEC2B28),
        borderRadius: BorderRadius.circular(16),
      );
}
