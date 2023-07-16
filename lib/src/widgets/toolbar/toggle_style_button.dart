import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/documents/style.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../utils/widgets.dart';
import '../controller.dart';
import '../toolbar.dart';

typedef ToggleStyleButtonBuilder = Widget Function(
  BuildContext context,
  Attribute attribute,
  Widget icon,
  Color selectedColor,
  Color unselectedColor,
  Color disabledColor,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed, [
  double iconSize,
  QuillIconTheme? iconTheme,
]);

class ToggleStyleButton extends StatefulWidget {
  const ToggleStyleButton({
    required this.attribute,
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.selectedColor,
    this.unselectedColor,
    this.disabledColor,
    this.fillColor,
    this.childBuilder = defaultToggleStyleButtonBuilder,
    this.iconTheme,
    this.afterButtonPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final Attribute attribute;

  final Widget icon;
  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final ToggleStyleButtonBuilder childBuilder;

  ///Specify an icon theme for the icons in the toolbar
  final QuillIconTheme? iconTheme;

  final VoidCallback? afterButtonPressed;
  final String? tooltip;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? disabledColor;

  @override
  _ToggleStyleButtonState createState() => _ToggleStyleButtonState();
}

class _ToggleStyleButtonState extends State<ToggleStyleButton> {
  bool? _isToggled;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  Widget build(BuildContext context) {
    return UtilityWidgets.maybeTooltip(
      message: widget.tooltip,
      child: widget.childBuilder(
        context,
        widget.attribute,
        widget.icon,
        widget.selectedColor ?? Colors.white,
        widget.unselectedColor ?? Colors.white,
        widget.disabledColor ?? Colors.white,
        widget.fillColor,
        _isToggled,
        _toggleAttribute,
        widget.afterButtonPressed,
        widget.iconSize,
        widget.iconTheme,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  void _didChangeEditingValue() {
    setState(() => _isToggled = _getIsToggled(_selectionStyle.attributes));
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    if (widget.attribute.key == Attribute.list.key || widget.attribute.key == Attribute.script.key) {
      final attribute = attrs[widget.attribute.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == widget.attribute.value;
    }
    return attrs.containsKey(widget.attribute.key);
  }

  void _toggleAttribute() {
    widget.controller.formatSelection(_isToggled! ? Attribute.clone(widget.attribute, null) : widget.attribute);
  }
}

Widget defaultToggleStyleButtonBuilder(
  BuildContext context,
  Attribute attribute,
  Widget icon,
  Color selectedColor,
  Color unselectedColor,
  Color disabledColor,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed, [
  double iconSize = kDefaultIconSize,
  QuillIconTheme? iconTheme,
]) {
  final isEnabled = onPressed != null;
  final fill = isEnabled
      ? isToggled == true
          ? selectedColor
          : unselectedColor
      : disabledColor;
  return Container(
    padding: const EdgeInsets.only(left: 14, right: 14),
    height: 48,
    decoration: BoxDecoration(
      color: selectedColor,
      borderRadius: const BorderRadius.all(Radius.circular(7)),
    ),
    child: QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      icon: icon,
      fillColor: fill,
      onPressed: onPressed,
      afterPressed: afterPressed,
      borderRadius: iconTheme?.borderRadius ?? 2,
    ),
  );
}
