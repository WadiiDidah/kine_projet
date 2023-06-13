import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeSlotCheckbox extends StatefulWidget {
  final String timeSlot;
  final ValueChanged<bool>? onChanged;

  const TimeSlotCheckbox({
    required this.timeSlot,
    this.onChanged, required bool isSelected,
  });

  @override
  _TimeSlotCheckboxState createState() => _TimeSlotCheckboxState();
}

class _TimeSlotCheckboxState extends State<TimeSlotCheckbox> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _isSelected,
          onChanged: (newValue) {
            setState(() {
              _isSelected = newValue!;
              if (widget.onChanged != null) {
                widget.onChanged!(newValue);
              }
            });
          },
        ),
        Text(widget.timeSlot),
      ],
    );
  }
}
