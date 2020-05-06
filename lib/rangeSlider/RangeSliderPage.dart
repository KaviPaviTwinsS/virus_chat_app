import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';


class RangeSliderSample extends StatefulWidget {
  SliderListener msliderListener;
  RangeSliderSample(SliderListener sliderListener){
    this.msliderListener = sliderListener;
  }

  @override
  _RangeSliderSampleState createState() => _RangeSliderSampleState(msliderListener);
}

class _RangeSliderSampleState extends State<RangeSliderSample> {

  double _lowerValue = 0.0;
  double _upperValue = 100.0;
  SliderListener sliderListener;


  _RangeSliderSampleState(SliderListener msliderListener){
    sliderListener = msliderListener;
  }

  @override
  void initState() {
    super.initState();
//    sliderListener.SliderChangeListener(_upperValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
              children: <Widget>[
                frs.RangeSlider(
                  min: 0.0,
                  max: 1000.0,
                  lowerValue: _lowerValue,
                  upperValue: _upperValue,
                  divisions: 10,
                  showValueIndicator: true,
                  valueIndicatorMaxDecimals: 1,
                  onChanged: (double newLowerValue, double newUpperValue) {
                    setState(() {
                      _lowerValue = newLowerValue;
                      _upperValue = newUpperValue;
                    });
                  },
                  onChangeStart:
                      (double startLowerValue, double startUpperValue) {
                    print(
                        'Started with values: $startLowerValue and $startUpperValue');
                  },
                  onChangeEnd: (double newLowerValue, double newUpperValue) {
                    print(
                        'Ended with values: $newLowerValue and $newUpperValue');
                    sliderListener.SliderChangeListener(newUpperValue);
                  },
                ),
                Container(
                  child: Text('My selected geofence $_upperValue metre',style: TextStyle(color: text_color,fontFamily: 'GoogleSansRegular'),),
                ),
              ]
      );
  }


}

// ---------------------------------------------------
// Helper class aimed at simplifying the way to
// automate the creation of a series of RangeSliders,
// based on various parameters
//
// This class is to be used to demonstrate the appearance
// customization of the RangeSliders
// ---------------------------------------------------
class RangeSliderData {
  double min;
  double max;
  double lowerValue;
  double upperValue;
  int divisions;
  bool showValueIndicator;
  int valueIndicatorMaxDecimals;
  bool forceValueIndicator;
  Color overlayColor;
  Color activeTrackColor;
  Color inactiveTrackColor;
  Color thumbColor;
  Color valueIndicatorColor;
  Color activeTickMarkColor;

  static const Color defaultActiveTrackColor = const Color(0xFF0175c2);
  static const Color defaultInactiveTrackColor = const Color(0x3d0175c2);
  static const Color defaultActiveTickMarkColor = const Color(0x8a0175c2);
  static const Color defaultThumbColor = const Color(0xFF0175c2);
  static const Color defaultValueIndicatorColor = const Color(0xFF0175c2);
  static const Color defaultOverlayColor = const Color(0x290175c2);

  RangeSliderData({
    this.min,
    this.max,
    this.lowerValue,
    this.upperValue,
    this.divisions,
    this.showValueIndicator: true,
    this.valueIndicatorMaxDecimals: 1,
    this.forceValueIndicator: false,
    this.overlayColor: defaultOverlayColor,
    this.activeTrackColor: defaultActiveTrackColor,
    this.inactiveTrackColor: defaultInactiveTrackColor,
    this.thumbColor: defaultThumbColor,
    this.valueIndicatorColor: defaultValueIndicatorColor,
    this.activeTickMarkColor: defaultActiveTickMarkColor,
  });

  // Returns the values in text format, with the number
  // of decimals, limited to the valueIndicatedMaxDecimals
  //
  String get lowerValueText =>
      lowerValue.toStringAsFixed(valueIndicatorMaxDecimals);

  String get upperValueText =>
      upperValue.toStringAsFixed(valueIndicatorMaxDecimals);

  // Builds a RangeSlider and customizes the theme
  // based on parameters
  //
  Widget build(BuildContext context, frs.RangeSliderCallback callback) {
    return Container(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          /* Container(
            constraints: BoxConstraints(
              minWidth: 40.0,
              maxWidth: 40.0,
            ),
            child: Text(lowerValueText),
          ),*/
          /*        Expanded(
            child: SliderTheme(
              // Customization of the SliderTheme
              // based on individual definitions
              // (see rangeSliders in _RangeSliderSampleState)
              data: SliderTheme.of(context).copyWith(
                overlayColor: overlayColor,
                activeTickMarkColor: activeTickMarkColor,
                activeTrackColor: activeTrackColor,
                inactiveTrackColor: inactiveTrackColor,
                //trackHeight: 8.0,
                thumbColor: thumbColor,
                valueIndicatorColor: valueIndicatorColor,
                showValueIndicator: showValueIndicator
                    ? ShowValueIndicator.always
                    : ShowValueIndicator.onlyForDiscrete,
              ),
              child: frs.RangeSlider(
                min: min,
                max: max,
                lowerValue: lowerValue,
                upperValue: upperValue,
                divisions: divisions,
                showValueIndicator: showValueIndicator,
                valueIndicatorMaxDecimals: valueIndicatorMaxDecimals,
                onChanged: (double lower, double upper) {
                  // call
                  callback(lower, upper);
                },
              ),
            ),
          ),*/
          /*Container(
            constraints: BoxConstraints(
              minWidth: 40.0,
              maxWidth: 40.0,
            ),
            child: Text(upperValueText),
          ),*/
        ],
      ),
    );
  }
}
