import 'package:flutter/material.dart';

import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/forms/app_text_field_widget.dart';

/// Password Input — COMPONENTS.md Bölüm 5.3: Text Input'un, sağda
/// göster/gizle göz ikonu eklenmiş varyantı. Yalnızca Authentication
/// ekranlarında kullanıldığı için `features/authentication/presentation/widgets/`
/// altında feature-local kalır (FOLDER_STRUCTURE.md Bölüm 6.3 — 2+ feature
/// kullanınca `shared/`e taşınır).
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.onChanged,
    this.hintText,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      hintText: widget.hintText,
      obscureText: _obscure,
      suffixIcon: AppIconButton(
        icon: _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        semanticLabel: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
