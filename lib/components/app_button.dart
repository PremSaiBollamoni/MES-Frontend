import 'package:flutter/material.dart';
import '../utils/theme_tokens.dart';

/// Primary action - a rich teal gradient fill with a soft colored glow beneath it,
/// rather than a flat solid color. [color] overrides the fill with a plain flat color
/// instead of the default gradient (still glowing) when a screen needs a specific
/// non-teal accent (e.g. a destructive action reusing this same button shape).
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? color;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;
    final glowColor = color ?? ThemeTokens.primary;

    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        child: Ink(
          decoration: BoxDecoration(
            gradient: color == null && !disabled ? ThemeTokens.primaryGradient : null,
            color: color == null
                ? (disabled ? ThemeTokens.primary.withValues(alpha: 0.35) : null)
                : (disabled ? color!.withValues(alpha: 0.35) : color),
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            boxShadow: disabled
                ? null
                : [BoxShadow(color: glowColor.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            onTap: disabled ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, size: 17, color: Colors.white), const SizedBox(width: 9.0)],
                        Flexible(
                          child: Text(
                            label.toUpperCase(),
                            style: ThemeTokens.buttonTextLarge.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary action - hairline-outlined, ink text, transparent fill.
class AppGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color color;

  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color = ThemeTokens.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: const BorderSide(color: ThemeTokens.hairlineStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
        ),
        child: isLoading
            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 17, color: color), const SizedBox(width: 9.0)],
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      style: ThemeTokens.buttonTextLarge.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
