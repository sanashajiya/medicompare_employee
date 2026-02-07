import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputField({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpValue {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    // Handle forward navigation when digit is entered
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Handle backward navigation when digit is deleted (backspace)
    else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _otpValue;
    widget.onChanged?.call(otp);

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) => _buildOtpBox(index)),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 40,
      height: 40,
      child: RawKeyboardListener(
        focusNode: FocusNode(), // RawKeyboardListener needs its own focus node
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            // Detect backspace key
            if (event.logicalKey.keyLabel == 'Backspace' ||
                event.data.logicalKey.keyId == 0x100000008) {
              if (_controllers[index].text.isEmpty && index > 0) {
                // If current box is empty, move to previous box and clear it
                _controllers[index - 1].clear();
                _focusNodes[index - 1].requestFocus();
                _onChanged(
                  index - 1,
                  '',
                ); // Trigger onChanged for the cleared previous box
              } else if (_controllers[index].text.isNotEmpty) {
                // If current box has content, clear it
                _controllers[index].clear();
                _onChanged(
                  index,
                  '',
                ); // Trigger onChanged for the cleared current box
              }
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.all(0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.length > 1) {
              // Handle paste - take only first character
              _controllers[index].text = value[0];
              _controllers[index].selection = TextSelection.fromPosition(
                const TextPosition(offset: 1),
              );
            }
            _onChanged(index, _controllers[index].text);
          },
          onTap: () {
            _controllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _controllers[index].text.length),
            );
          },
          onEditingComplete: () {
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
          },
          onSubmitted: (_) {
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
          },
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}
