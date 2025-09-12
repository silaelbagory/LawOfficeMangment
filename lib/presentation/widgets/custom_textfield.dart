import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/constants.dart';

enum TextFieldType {
  text,
  email,
  password,
  phone,
  multiline,
  number,
  search,
}

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextFieldType type;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final bool showCounter;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isDense;
  final double? width;
  final double? height;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.type = TextFieldType.text,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.filled = true,
    this.fillColor,
    this.contentPadding,
    this.borderRadius,
    this.showCounter = false,
    this.autofocus = false,
    this.focusNode,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDense = false,
    this.width,
    this.height,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;


  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    
    _focusNode.addListener(() {
      setState(() {
        // Focus state changed
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: _obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        textInputAction: widget.textInputAction ?? _getTextInputAction(),
        keyboardType: widget.keyboardType ?? _getKeyboardType(),
        inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
        autofocus: widget.autofocus,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.label != null 
              ? '${widget.label}${widget.isRequired ? ' *' : ''}'
              : null,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          prefixText: widget.prefixText,
          suffixText: widget.suffixText,
          filled: widget.filled,
          fillColor: widget.fillColor ?? colorScheme.surface,
          contentPadding: widget.contentPadding ?? _getContentPadding(),
          border: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
          ),
          counterText: widget.showCounter ? null : '',
          isDense: widget.isDense,
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.type == TextFieldType.search) {
      return Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
    
    return widget.suffixIcon;
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputAction.next;
      case TextFieldType.password:
        return TextInputAction.done;
      case TextFieldType.multiline:
        return TextInputAction.newline;
      case TextFieldType.search:
        return TextInputAction.search;
      default:
        return TextInputAction.next;
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.type) {
      case TextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ];
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return [];
    }
  }

  EdgeInsetsGeometry _getContentPadding() {
    if (widget.isDense) {
      return const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      );
    }
    
    return const EdgeInsets.all(AppConstants.defaultPadding);
  }
}

// Predefined text field variants for common use cases
class EmailTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final String? helperText;
  final String? errorText;

  const EmailTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = false,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Email',
      hint: hint ?? 'Enter your email',
      initialValue: initialValue,
      type: TextFieldType.email,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      isRequired: isRequired,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: const Icon(Icons.email),
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final String? helperText;
  final String? errorText;

  const PasswordTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = false,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Password',
      hint: hint ?? 'Enter your password',
      initialValue: initialValue,
      type: TextFieldType.password,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      isRequired: isRequired,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: const Icon(Icons.lock),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final String? helperText;
  final String? errorText;

  const PhoneTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = false,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Phone Number',
      hint: hint ?? 'Enter your phone number',
      initialValue: initialValue,
      type: TextFieldType.phone,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      isRequired: isRequired,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: const Icon(Icons.phone),
    );
  }
}

class SearchTextField extends StatelessWidget {
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final String? helperText;
  final String? errorText;

  const SearchTextField({
    super.key,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: hint ?? 'Search...',
      initialValue: initialValue,
      type: TextFieldType.search,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      helperText: helperText,
      errorText: errorText,
    );
  }
}

class MultilineTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final bool isRequired;
  final String? helperText;
  final String? errorText;

  const MultilineTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 3,
    this.maxLength,
    this.isRequired = false,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      initialValue: initialValue,
      type: TextFieldType.multiline,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      isRequired: isRequired,
      helperText: helperText,
      errorText: errorText,
      showCounter: maxLength != null,
    );
  }
}
