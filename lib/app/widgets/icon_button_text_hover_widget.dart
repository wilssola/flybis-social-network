// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class IconButtonTextHoverWidget extends StatefulWidget {
  final Widget? icon;
  final String? label;
  final Function? onPressed;
  final ButtonStyle? style;

  const IconButtonTextHoverWidget({
    Key? key,
    this.icon,
    this.label,
    this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  _IconButtonTextHoverWidgetState createState() =>
      _IconButtonTextHoverWidgetState();
}

class _IconButtonTextHoverWidgetState extends State<IconButtonTextHoverWidget> {
  final Matrix4 nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
  final Matrix4 hoverTransform = Matrix4.identity()..translate(5, 0, 0);

  bool _hovering = false;

  void _mouseEnter(bool hover) {
    setState(() {
      _hovering = hover;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextButton.icon(
          icon: widget.icon!,
          label: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              child: Text(widget.label!),
              width: _hovering ? widget.label!.length * 10 : 0,
            ),
            opacity: _hovering ? 1 : 0,
          ),
          onPressed: widget.onPressed as void Function()?,
          style: widget.style,
        ),
        transform: _hovering ? hoverTransform : nonHoverTransform,
      ),
    );
  }
}
