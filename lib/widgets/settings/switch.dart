import 'package:flutter/material.dart';

// Implements an on/off switch widget for setting
class SwitchSetting extends StatefulWidget {
  final String settingName;
  final String? offSettingName;
  final Color enableColor;
  final bool switchValue;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const SwitchSetting({
    this.offSettingName,
    required this.settingName,
    required this.switchValue,
    required this.enableColor,
    required this.onChanged,
    this.isEnabled = true,
    super.key,
  });

  @override
  State<SwitchSetting> createState() => _SwitchSettingData();
}

class _SwitchSettingData extends State<SwitchSetting> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.switchValue;
  }

  String getSwitchTitle() {
    if (widget.offSettingName != null && !_value) {
      return widget.offSettingName!;
    }
    return widget.settingName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.5),
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(getSwitchTitle()),
          Switch(
            // This bool value toggles the switch.
            value: _value,
            activeColor: widget.isEnabled ? widget.enableColor : Colors.grey,
            onChanged:
                widget.isEnabled
                    ? (bool value) {
                      widget.onChanged(value);
                      // This is called when the user toggles the switch.
                      setState(() {
                        _value = value;
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
