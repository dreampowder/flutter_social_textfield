import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/controller/social_text_editing_controller.dart';

class DefaultSocialTextFieldController extends StatefulWidget {

  final SocialTextEditingController textEditingController;
  final Widget child;
  final Map<DetectedType, PreferredSize Function(BuildContext context)>? detectionBuilders;

  DefaultSocialTextFieldController({required this.child,required this.textEditingController, this.detectionBuilders});

  @override
  _DefaultSocialTextFieldControllerState createState() => _DefaultSocialTextFieldControllerState();
}

class _DefaultSocialTextFieldControllerState extends State<DefaultSocialTextFieldController> {

  bool willShowDetectionContent = false;
  DetectedType _detectedType = DetectedType.plain_text;

  StreamSubscription<SocialContentDetection>? _streamSubscription;

  Map<DetectedType, double> heightMap = Map();

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.textEditingController.subscribeToDetection(onDetectContent);
    DetectedType.values.forEach((type) {
      if (widget.detectionBuilders?[type] != null) {
        heightMap[type] = widget.detectionBuilders?[type]!(context).preferredSize.height ?? 0;
      } else {
        heightMap[type] = 0;
      }
    });
    print("HeightMap: $heightMap");
  }

  void onDetectContent(SocialContentDetection detection){
    print("detection");
    if(detection.type != _detectedType){
      print("new detection");
      setState(() {
        _detectedType = detection.type;
      });
    }
  }

  bool doesHaveBuilderForCurrentType(){
    return (widget.detectionBuilders?.containsKey(_detectedType) ?? false);
  }

  double getChildBottomHeight(){
    if(!doesHaveBuilderForCurrentType()){
      return 0;
    }
    print("${heightMap[_detectedType] ?? 0}");
    return heightMap[_detectedType] ?? 0;
  }

  PreferredSize getDetectionContent(){
    if(!(widget.detectionBuilders?.containsKey(_detectedType) ?? false)){
      return PreferredSize(child: Container(), preferredSize: Size.zero);
    }
    return widget.detectionBuilders?[_detectedType]!(context) ?? PreferredSize(child: Container(), preferredSize: Size.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 200),
          top: 0,
          left: 0,
          right: 0,
          bottom: getChildBottomHeight(),
          child: widget.child),
        AnimatedPositioned(
          duration: Duration(milliseconds: 200),
          bottom: 0,
          left: 0,
          right: 0,
          height: getChildBottomHeight(),
          child: getDetectionContent())
      ],
    );
  }
}
