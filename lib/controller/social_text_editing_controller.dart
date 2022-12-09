import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';



///An improved [TextEditingController] for using with any widget that accepts [TextEditingController].
///It uses [SocialTextSpanBuilder] for rendering the content.
///[_detectionStream] returns content of the current cursor position. Positions are calculated by the cyrrent location of the word
///Configuration is made by calling setter functions.
///example:
///     _textEditingController = SocialTextEditingController()
///       ..setTextStyle(DetectedType.mention, TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)))
///      ..setTextStyle(DetectedType.url, TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
///      ..setTextStyle(DetectedType.hashtag, TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))
///      ..setRegexp(DetectedType.mention, Regexp("your_custom_regex_pattern");
///
///There is also a helper function that can replaces range with the given value. In order to change cursor context, cursor moves to next word after replacement.
///
class SocialTextEditingController extends TextEditingController{

  StreamController<SocialContentDetection> _detectionStream = StreamController<SocialContentDetection>.broadcast();

  @override
  void dispose() {
    _detectionStream.close();
    super.dispose();
  }

  final Map<DetectedType, TextStyle> detectionTextStyles = Map();

  final Map<DetectedType, RegExp> _regularExpressions = {
    DetectedType.mention:atSignRegExp,
    DetectedType.hashtag:hashTagRegExp,
    DetectedType.url:urlRegex,
    DetectedType.emoji:emojiRegex,
  };

  StreamSubscription<SocialContentDetection> subscribeToDetection(Function(SocialContentDetection detected) listener){
    return _detectionStream.stream.listen(listener);
  }

  void setTextStyle(DetectedType type, TextStyle style){
    detectionTextStyles[type] = style;
  }

  void setRegexp(DetectedType type, RegExp regExp){
    _regularExpressions[type] = regExp;
  }

  void replaceRange(String newValue, TextRange range){
    // print("newValue: $newValue, range: $range: ${range.textInside(text)}");
    var newText = text.replaceRange(range.start, range.end, newValue);
    var newRange = TextRange(start: range.start, end: range.start + newValue.length);
    // print("Updated Range Content: [${newRange.textAfter(newText)}], text length: ${newText.length}, ${newRange.end}");
    bool isAtTheEndOfText = (newRange.textAfter(newText) == " " && newRange.end == newText.length - 1);
    if(isAtTheEndOfText){
      newText += " ";
    }
    TextSelection newTextSelection = TextSelection(baseOffset: newRange.end + 1, extentOffset: newRange.end + 1);
    value = value.copyWith(text: newText, selection: newTextSelection);
  }

  void _processNewValue(TextEditingValue newValue){
    var currentPosition = newValue.selection.baseOffset;
    if(currentPosition == -1){
      currentPosition = 0;
    }
    if(currentPosition >newValue.text.length){
      currentPosition = newValue.text.length - 1;
    }
    var subString = newValue.text.substring(0,currentPosition);

    var lastPart = subString.split(" ").last.split("\n").last;
    var startIndex = currentPosition - lastPart.length;
    var detectionContent = newValue.text.substring(startIndex).split(" ").first.split("\n").first;
    _detectionStream.add(SocialContentDetection(getType(detectionContent), TextRange(start: startIndex, end: startIndex + detectionContent.length), detectionContent));
  }
  
  DetectedType getType(String word){
    return _regularExpressions.keys.firstWhere((type) => _regularExpressions[type]!.hasMatch(word),orElse: ()=>DetectedType.plain_text);
  }

  @override
  set value(TextEditingValue newValue) {

    if(newValue.selection.baseOffset >= newValue.text.length){
      print("will add space");
      newValue = newValue
          .copyWith(
          text: newValue.text.trimRight() + " ",
          selection: newValue.selection.copyWith(baseOffset: newValue.text.length, extentOffset: newValue.text.length));
    }
    if(newValue.text == " "){
      newValue = newValue
          .copyWith(
          text: "",
          selection: newValue.selection.copyWith(baseOffset: 0, extentOffset: 0));
    }
    _processNewValue(newValue);
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return SocialTextSpanBuilder(regularExpressions: _regularExpressions,defaultTextStyle: style,detectionTextStyles: detectionTextStyles).build(text);
  }
}