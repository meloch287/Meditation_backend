import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.blur = 12.0,
    this.opacity = 0.15,
    this.isDisabled = false,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderWidth = 1.5,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ??
        (isDisabled ? Colors.grey.withOpacity(0.1) : Colors.white.withOpacity(opacity));
    final effectiveBorderColor = borderColor ??
        (isDisabled ? Colors.grey.withOpacity(0.3) : Colors.white.withOpacity(0.4));
    final effectiveTextColor = textColor ??
        (isDisabled ? Colors.grey : Colors.white);

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: width,
        height: height ?? 56,
        decoration: BoxDecoration(
          boxShadow: shadows ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: borderWidth,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveBackgroundColor,
                    effectiveBackgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}