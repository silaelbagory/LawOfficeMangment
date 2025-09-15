import 'package:flutter/material.dart';

import '../../core/utils/constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  icon,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? child;
  final String? tooltip;

  const CustomButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.child,
    this.tooltip,
  }) : assert(text != null || icon != null || child != null, 'Button must have text, icon, or child');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget button = _buildButton(context, theme, isDark);
    
    // Only show Tooltip if Overlay is available and we're in a proper context
    if (tooltip != null) {
      try {
        // Check if we can find an Overlay in the current context
        Overlay.of(context, rootOverlay: false);
        {
          button = Tooltip(
            message: tooltip!,
            child: button,
          );
        }
      } catch (e) {
        // If Overlay is not available, just return the button without tooltip
        // This prevents the "No Overlay widget found" error
      }
    }
    
    return button;
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isDark) {
    final buttonStyle = _getButtonStyle(theme, isDark);
    final buttonPadding = _getButtonPadding();
    final buttonHeight = _getButtonHeight();
    final buttonBorderRadius = _getButtonBorderRadius();

    if (type == ButtonType.icon && icon != null) {
      return SizedBox(
        width: width ?? buttonHeight,
        height: height ?? buttonHeight,
        child: IconButton(
          onPressed: _isButtonEnabled() ? onPressed : null,
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        buttonStyle.foregroundColor?.resolve({}) ?? theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              : Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: buttonStyle.backgroundColor?.resolve({}),
            foregroundColor: buttonStyle.foregroundColor?.resolve({}),
            shape: RoundedRectangleBorder(
              borderRadius: buttonBorderRadius,
              side: buttonStyle.side?.resolve({}) ?? BorderSide.none,
            ),
          ),
        ),
      );
    }

    Widget buttonChild = child ??
        (isLoading
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          buttonStyle.foregroundColor?.resolve({}) ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (text != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text!,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _getTextSize(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize()),
                    if (text != null) const SizedBox(width: 8),
                  ],
                  if (text != null) 
                    Flexible(
                      child: Text(
                        text!,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _getTextSize(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ));

    if (type == ButtonType.text) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? buttonHeight,
        child: TextButton(
          onPressed: _isButtonEnabled() ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: buttonStyle.foregroundColor?.resolve({}),
            padding: buttonPadding,
            minimumSize: Size(width ?? 120, height ?? buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: buttonBorderRadius,
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? buttonHeight,
      child: ElevatedButton(
        onPressed: _isButtonEnabled() ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonStyle.backgroundColor?.resolve({}),
          foregroundColor: buttonStyle.foregroundColor?.resolve({}),
          padding: buttonPadding,
          minimumSize: Size(width ?? 120, height ?? buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
            side: buttonStyle.side?.resolve({}) ?? BorderSide.none,
          ),
          elevation: type == ButtonType.outline ? 0 : 2,
        ),
        child: buttonChild,
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;
    
    switch (type) {
      case ButtonType.primary:
        return ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? colorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.all(
            textColor ?? colorScheme.onPrimary,
          ),
        );
      case ButtonType.secondary:
        return ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? colorScheme.secondary,
          ),
          foregroundColor: WidgetStateProperty.all(
            textColor ?? colorScheme.onSecondary,
          ),
        );
      case ButtonType.outline:
        return ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            textColor ?? colorScheme.primary,
          ),
          side: WidgetStateProperty.all(
            BorderSide(
              color: borderColor ?? colorScheme.primary,
              width: 1.5,
            ),
          ),
        );
      case ButtonType.text:
        return ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            textColor ?? colorScheme.primary,
          ),
        );
      case ButtonType.icon:
        return ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? colorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.all(
            textColor ?? colorScheme.onPrimary,
          ),
        );
    }
  }

  EdgeInsetsGeometry _getButtonPadding() {
    if (padding != null) return padding!;
    
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding * 1.5,
          vertical: AppConstants.largePadding,
        );
    }
  }

  double _getButtonHeight() {
    if (height != null) return height!;
    
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getTextSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  BorderRadius _getButtonBorderRadius() {
    if (borderRadius != null) return borderRadius!;
    
    return BorderRadius.circular(AppConstants.borderRadius);
  }

  bool _isButtonEnabled() {
    return !isLoading && !isDisabled && onPressed != null;
  }
}

// Predefined button variants for common use cases
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonSize size;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = ButtonSize.medium,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonSize size;
  final IconData? icon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = ButtonSize.medium,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonSize size;
  final IconData? icon;
  final double? width;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = ButtonSize.medium,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: ButtonType.outline,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonSize size;
  final IconData? icon;
  final double? width;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = ButtonSize.medium,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: ButtonType.text,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      icon: icon,
      onPressed: onPressed,
      type: ButtonType.icon,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: backgroundColor,
      textColor: iconColor,
      tooltip: tooltip,
    );
  }
}
