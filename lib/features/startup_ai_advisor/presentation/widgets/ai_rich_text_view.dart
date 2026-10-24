import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A sleek custom markdown & rich-text parser and renderer
/// supporting headers, bold text, numbered/bulleted lists, and quotes.
class AiRichTextView extends StatelessWidget {
  const AiRichTextView({
    super.key,
    required this.content,
    this.primaryColor = AppColors.primaryDark,
    this.textColor = AppColors.textPrimary,
  });

  final String content;
  final Color primaryColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            trimmed.substring(4),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primaryColor,
              letterSpacing: -0.2,
            ),
          ),
        ));
      } else if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            trimmed.substring(3),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: primaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ));
      } else if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            trimmed.substring(2),
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: -0.4,
            ),
          ),
        ));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7, right: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: _buildFormattedText(trimmed.substring(2), textColor),
              ),
            ],
          ),
        ));
      } else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        final match = RegExp(r'^(\d+)\.\s').firstMatch(trimmed)!;
        final numStr = match.group(1)!;
        final textPart = trimmed.substring(match.end);

        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 2, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  numStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: _buildFormattedText(textPart, textColor),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildFormattedText(trimmed, textColor),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildFormattedText(String text, Color baseColor) {
    final spans = <TextSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isBold = i % 2 == 1;

      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          color: isBold ? AppColors.secondary : baseColor,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          fontSize: 14,
          height: 1.5,
        ),
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
