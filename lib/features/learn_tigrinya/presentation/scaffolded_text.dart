import 'package:flutter/material.dart';

/// Parses a string containing `{}` brackets and returns a `RichText` widget.
/// The text inside `{}` is styled with the [highlightColor] and bold weight.
/// The text outside is styled with [baseStyle].
/// E.g., "{እ}በልዕ" will render "እ" in bold highlight color and "በልዕ" in base color.
class ScaffoldedText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final Color highlightColor;
  final TextAlign textAlign;

  const ScaffoldedText({
    super.key,
    required this.text,
    required this.baseStyle,
    required this.highlightColor,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = [];
    final highlightStyle = baseStyle.copyWith(
      color: highlightColor,
      fontWeight: FontWeight.bold,
    );

    int currentIndex = 0;
    while (currentIndex < text.length) {
      final startIndex = text.indexOf('{', currentIndex);
      if (startIndex == -1) {
        // No more '{', add the rest of the string
        spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
        break;
      }

      final endIndex = text.indexOf('}', startIndex);
      if (endIndex == -1) {
        // Unmatched '{', treat it as literal
        spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
        break;
      }

      // Add text before the '{'
      if (startIndex > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, startIndex), style: baseStyle));
      }

      // Add the highlighted text without the brackets
      final highlightedStr = text.substring(startIndex + 1, endIndex);
      spans.add(TextSpan(text: highlightedStr, style: highlightStyle));

      currentIndex = endIndex + 1;
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(children: spans),
    );
  }
}

/// Helper to strip `{}` brackets for logical comparisons
String stripScaffolding(String text) {
  return text.replaceAll('{', '').replaceAll('}', '');
}
