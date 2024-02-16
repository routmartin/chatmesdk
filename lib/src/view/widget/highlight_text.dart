import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String highlightText;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;

  const HighlightText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.highlightText = '',
  }) : super(key: key);

  List<TextSpan> getTextSpan(context) {
    var result = <TextSpan>[];
    var target = text;
    var defaultStyle = style ?? Theme.of(context).textTheme.bodyText2;
    if (highlightText.isNotEmpty) {
      while (target.toLowerCase().contains(highlightText.toLowerCase())) {
        final position = target.toLowerCase().indexOf(highlightText.toLowerCase());
        result.add(
          TextSpan(
            text: target.substring(0, position),
            style: defaultStyle,
          ),
        );
        result.add(
          TextSpan(
            text: target.substring(position, position + highlightText.length),
            style: defaultStyle?.copyWith(
              backgroundColor: Colors.yellow,
            ),
          ),
        );
        target = target.substring(position + highlightText.length);
      }
    }
    result.add(
      TextSpan(
        text: target,
        style: defaultStyle,
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      text: TextSpan(
        style: style,
        children: getTextSpan(context),
      ),
    );
  }
}
