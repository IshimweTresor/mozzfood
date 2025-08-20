import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.label,
    required this.hintText,
    this.prefixIcon,
    this.prefix,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          obscureText: widget.isPassword ? _obscureText : false,
          onChanged: widget.onChanged,
          style: const TextStyle(color: AppColors.onBackground, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
            prefixIcon:
                widget.prefix ??
                (widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                    : null),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
