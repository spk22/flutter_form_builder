import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_form_builder/src/hex_color.dart';

enum ColorPickerType { ColorPicker, MaterialPicker, BlockPicker, SlidePicker }

class FormBuilderColorPicker extends FormBuilderField<Color> {
  final TextEditingController controller;
  final FocusNode focusNode;

  final ColorPickerType colorPickerType;
  final TextCapitalization textCapitalization;

  final TextAlign textAlign;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextDirection textDirection;
  final bool autofocus;

  final bool obscureText;

  final bool autocorrect;

  final bool maxLengthEnforced;

  final int maxLines;

  final bool expands;

  final bool showCursor;
  final int minLines;
  final int maxLength;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onFieldSubmitted;
  final List<TextInputFormatter> inputFormatters;
  final double cursorWidth;
  final Radius cursorRadius;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final InputCounterWidgetBuilder buildCounter;

  FormBuilderColorPicker({
    Key key,
    @required String attribute,
    AutovalidateMode autovalidateMode,
    bool enabled = true,
    Color initialValue,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Color> onChanged,
    FormFieldSetter<Color> onSaved,
    bool readOnly = false,
    ValueTransformer<Color> valueTransformer,
    List<FormFieldValidator<Color>> validators = const [],
    this.controller,
    this.focusNode,
    this.colorPickerType = ColorPickerType.ColorPicker,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.maxLengthEnforced = true,
    this.maxLines = 1,
    this.expands = false,
    this.showCursor,
    this.minLines,
    this.maxLength,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.buildCounter,
  }) : super(
          key: key,
          attribute: attribute,
          readOnly: readOnly,
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          initialValue: initialValue,
          decoration: decoration,
          onChanged: onChanged,
          onSaved: onSaved,
          valueTransformer: valueTransformer,
          validators: validators,
        );

  @override
  _FormBuilderColorPickerState createState() => _FormBuilderColorPickerState();
}

class _FormBuilderColorPickerState
    extends FormBuilderFieldState<FormBuilderColorPicker, Color, String> {
  final _focusNode = FocusNode();
  TextEditingController _textEditingController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _textEditingController;

  /// Converts a Color Hex code value into a Color value
  @override
  Color initialValueTransformer(String storedInitialValue) {
    return HexColor.fromHex(storedInitialValue);
  }

  FocusNode get effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: initialValue?.toHex());
    widget.focusNode?.addListener(_handleFocus);
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Color>(
      key: fieldKey,
      enabled: widget.enabled,
      initialValue: initialValue,
      autovalidateMode: widget.autovalidateMode,
      validator: (val) => validate(val),
      onSaved: (val) => save(val),
      builder: (FormFieldState<Color> field) {
        _effectiveController.text = field.value?.toHex();
        final defaultBorderColor = Colors.grey;

        return TextField(
          style: widget.style,
          decoration: widget.decoration.copyWith(
            enabled: widget.enabled,
            errorText: field.errorText,
            suffixIcon: LayoutBuilder(
              key: ObjectKey(field.value),
              builder: (context, constraints) {
                return Container(
                  height: constraints.minHeight,
                  width: constraints.minHeight,
                  decoration: BoxDecoration(
                    color: field.value ?? Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(constraints.minHeight / 2),
                    ),
                    border:
                        Border.all(color: field.value ?? defaultBorderColor),
                  ),
                );
              },
            ),
          ),
          enabled: widget.enabled,
          readOnly: true,
          controller: _effectiveController,
          focusNode: effectiveFocusNode,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          expands: widget.expands,
          scrollPadding: widget.scrollPadding,
          autocorrect: widget.autocorrect,
          textCapitalization: widget.textCapitalization,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          buildCounter: widget.buildCounter,
          cursorColor: widget.cursorColor,
          cursorRadius: widget.cursorRadius,
          cursorWidth: widget.cursorWidth,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          inputFormatters: widget.inputFormatters,
          keyboardAppearance: widget.keyboardAppearance,
          maxLength: widget.maxLength,
          maxLengthEnforced: widget.maxLengthEnforced,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          onEditingComplete: widget.onEditingComplete,
          // onFieldSubmitted: onFieldSubmitted,
          showCursor: widget.showCursor,
          strutStyle: widget.strutStyle,
          textDirection: widget.textDirection,
          textInputAction: widget.textInputAction,
        );
      },
    );
  }

  void _setColor(Color color) {
    assert(null != color);
    fieldKey.currentState.didChange(color);
    widget.onChanged?.call(color);
    _effectiveController.text = HexColor(color).toHex();
  }

  Future<void> _handleFocus() async {
    if (effectiveFocusNode.hasFocus && widget.enabled) {
      await Future.microtask(
          () => FocusScope.of(context).requestFocus(FocusNode()));
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          final materialLocalizations = MaterialLocalizations.of(context);
          var pickedColor = fieldKey.currentState.value ?? Colors.transparent;
          return AlertDialog(
            // title: null, //const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: Builder(builder: (context) {
                switch (widget.colorPickerType) {
                  case ColorPickerType.ColorPicker:
                    return ColorPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (Color val) {
                        pickedColor = val;
                      },
                      colorPickerWidth: 300,
                      displayThumbColor: true,
                      enableAlpha: true,
                      paletteType: PaletteType.hsl,
                      pickerAreaHeightPercent: 1.0,
                      //FIXME: Present these options to user
                      /*labelTextStyle: ,
                      pickerAreaBorderRadius: ,
                      showLabel: ,*/
                    );
                  case ColorPickerType.MaterialPicker:
                    return MaterialPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (Color val) {
                        pickedColor = val;
                      },
                      enableLabel: true, // only on portrait mode
                    );
                  case ColorPickerType.BlockPicker:
                    return BlockPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (Color val) {
                        pickedColor = val;
                      },
                      /*
                      availableColors: [],
                      itemBuilder: ,
                      layoutBuilder: ,
                      */
                    );
                  case ColorPickerType.SlidePicker:
                    return SlidePicker(
                      pickerColor: pickedColor,
                      onColorChanged: (Color val) {
                        pickedColor = val;
                      },
                    );
                  default:
                    throw 'Unknown ColorPickerType';
                }
              }),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(materialLocalizations.cancelButtonLabel),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              TextButton(
                child: Text(materialLocalizations.okButtonLabel),
                onPressed: () {
                  _setColor(pickedColor);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
    }
  }
}
