import 'package:flutter/material.dart';

class ResponsiveFormFieldRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  const ResponsiveFormFieldRow({super.key, required this.children, this.spacing = 16.0, this.breakpoint = 500.0});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < breakpoint;

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.expand((widget) => [widget, SizedBox(height: spacing)]).toList()..removeLast(),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.expand((widget) => [Expanded(child: widget), SizedBox(width: spacing)]).toList()
          ..removeLast(),
      );
    }
  }
}
