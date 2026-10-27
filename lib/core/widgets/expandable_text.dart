import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    this.maxLines = 5,
    this.style,
    this.initiallyExpanded = false,
  });

  final String text;
  final int maxLines;
  final TextStyle? style;
  final bool initiallyExpanded;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    if (_expanded) return Text(widget.text, style: style);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        final text = Text(
          widget.text,
          style: style,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
        );
        if (!overflows) return text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text,
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  'Read more',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
