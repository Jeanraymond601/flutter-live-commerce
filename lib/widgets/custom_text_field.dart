// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final bool filled;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final BorderRadius? borderRadius;
  final String? errorText;
  final bool showError;
  final bool required;
  final String? helperText;
  final bool showCounter;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textInputAction,
    this.focusNode,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.fillColor,
    this.filled = false,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.borderRadius,
    this.errorText,
    this.showError = true,
    this.required = false,
    this.helperText,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label avec astérisque si requis
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Text(
                  label,
                  style: labelStyle ?? Theme.of(context).textTheme.labelMedium,
                ),
                if (required)
                  const Padding(
                    padding: EdgeInsets.only(left: 2.0),
                    child: Text('*', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),

        // Champ de texte
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          textInputAction: textInputAction,
          focusNode: focusNode,
          style: style ?? Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon ?? (icon != null ? Icon(icon) : null),
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            filled: filled,
            fillColor: fillColor ?? Theme.of(context).cardColor,
            contentPadding: contentPadding ?? const EdgeInsets.all(16),
            border: border ?? _getDefaultBorder(context),
            enabledBorder: enabledBorder ?? _getDefaultBorder(context),
            focusedBorder: focusedBorder ?? _getFocusedBorder(context),
            errorBorder: errorBorder ?? _getErrorBorder(context),
            focusedErrorBorder: focusedErrorBorder ?? _getErrorBorder(context),
            errorText: showError ? errorText : null,
            helperText: helperText,
            counterText: showCounter ? null : '',
          ),
        ),

        // Texte d'aide
        if (helperText != null && helperText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              helperText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  InputBorder _getDefaultBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
    );
  }

  InputBorder _getFocusedBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
    );
  }

  InputBorder _getErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );
  }
}

// Variante avec préfixe
class PrefixedTextField extends StatelessWidget {
  final String prefix;
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const PrefixedTextField({
    super.key,
    required this.prefix,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      keyboardType: keyboardType,
      validator: validator,
      prefixIcon: Container(
        width: 60,
        alignment: Alignment.center,
        child: Text(prefix, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// Champ de recherche spécialisé
class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function()? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear ?? () => controller.clear(),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      ),
      onChanged: onChanged,
    );
  }
}

// Champ numérique avec stepper
class NumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final double min;
  final double max;
  final double step;
  final int? decimals;
  final String? Function(String?)? validator;

  const NumberTextField({
    super.key,
    required this.controller,
    required this.label,
    this.min = 0,
    this.max = double.infinity,
    this.step = 1,
    this.decimals,
    this.validator,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NumberTextFieldState createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  void _increment() {
    final currentValue = double.tryParse(widget.controller.text) ?? 0;
    final newValue = (currentValue + widget.step).clamp(widget.min, widget.max);
    widget.controller.text = _formatNumber(newValue);
    setState(() {});
  }

  void _decrement() {
    final currentValue = double.tryParse(widget.controller.text) ?? 0;
    final newValue = (currentValue - widget.step).clamp(widget.min, widget.max);
    widget.controller.text = _formatNumber(newValue);
    setState(() {});
  }

  String _formatNumber(double value) {
    if (widget.decimals != null) {
      return value.toStringAsFixed(widget.decimals!);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      keyboardType: TextInputType.numberWithOptions(
        decimal: widget.decimals != null,
      ),
      validator: widget.validator,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _decrement,
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _increment,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
