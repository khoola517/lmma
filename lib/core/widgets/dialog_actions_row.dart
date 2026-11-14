import 'package:flutter/material.dart';

/// صف موحد لأزرار الإجراءات في النوافذ الحوارية لضمان بقائها بجانب بعضها.
class DialogActionsRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const DialogActionsRow({
    super.key,
    required this.children,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spacedChildren.add(SizedBox(width: spacing));
      spacedChildren.add(children[i]);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: spacedChildren,
      ),
    );
  }
}

