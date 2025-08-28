import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

// Implements a single slider for the setting data
class SingleSlider extends StatefulWidget {
  final String settingName;
  final double minRange;
  final double maxRange;
  final bool isInt;
  final bool isEnabled;
  final double startValue;
  final ValueChanged<double> onChanged;

  const SingleSlider({
    required this.settingName,
    required this.minRange,
    required this.maxRange,
    required this.onChanged,
    this.startValue = 0.5,
    this.isInt = false,
    this.isEnabled = true,
    super.key,
  });

  @override
  State<SingleSlider> createState() => _SingleSliderData();
}

class _SingleSliderData extends State<SingleSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.startValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.5),
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.settingName),
          SfSlider(
            min: widget.minRange,
            max: widget.maxRange,
            showLabels: true,
            enableTooltip: true,
            thumbIcon: Text("${_value.toInt()}", textAlign: TextAlign.center),
            value: _value,
            onChanged:
                widget.isEnabled
                    ? (newValue) {
                      var castValue = newValue;
                      if (widget.isInt) {
                        castValue = castValue.round().toDouble();
                      }

                      widget.onChanged(castValue);
                      setState(() {
                        _value = castValue;
                        print("UPDATING SLIDER value: $_value");
                      });
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
