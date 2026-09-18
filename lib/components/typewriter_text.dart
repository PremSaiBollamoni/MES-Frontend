import 'package:flutter/material.dart';

/// Reveals [text] character-by-character over one slice ([interval]) of a shared
/// entrance [animation], with a blinking cursor while typing - used for the login
/// brand panel's wordmark instead of a plain fade-in.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Animation<double> animation;
  final Interval interval;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    required this.animation,
    required this.interval,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late final AnimationController _cursorBlink;
  late final CurvedAnimation _progress;

  @override
  void initState() {
    super.initState();
    _cursorBlink = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _progress = CurvedAnimation(parent: widget.animation, curve: widget.interval);
  }

  @override
  void dispose() {
    _cursorBlink.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progress, _cursorBlink]),
      builder: (context, _) {
        final charCount = (_progress.value * widget.text.length).ceil().clamp(0, widget.text.length);
        final done = charCount >= widget.text.length;
        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: widget.text.substring(0, charCount)),
              if (!done)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Opacity(
                    opacity: _cursorBlink.value,
                    child: Container(width: 3, height: (widget.style.fontSize ?? 16) * 0.85, color: widget.style.color),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
