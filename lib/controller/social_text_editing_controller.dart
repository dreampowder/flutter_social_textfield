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
    DetectedType.url:urlRegex
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
    print("text.length = ${text.length}");
    print("range.end: ${range.start + newValue.length}");
    var willAddSpaceAtEnd = (text.length-1) <= (range.start + newValue.length);
    var replacingText = "$newValue${willAddSpaceAtEnd ? " " : ""}";
    var replacedText = text.replaceRange(range.start, range.end+1, replacingText);
    var newCursorPosition = range.start+replacingText.length + (willAddSpaceAtEnd ? 0 : 1);
    print("$willAddSpaceAtEnd new Position: $newCursorPosition, new Length: ${replacedText.length}");
    // if(newCursorPosition == replacedText.length){
    //   newCursorPosition -= 1;
    // }
    print("Length: ${replacedText.length}, ${newCursorPosition}");
    if(newCursorPosition >= replacedText.length){
      newCursorPosition = replacedText.length-1;
    }
    value = value.copyWith(text: replacedText,selection: value.selection.copyWith(baseOffset: newCursorPosition,extentOffset: newCursorPosition),composing: value.composing);
  }

  void _processNewValue(TextEditingValue newValue){
    var currentPosition = newValue.selection.baseOffset;
    if(currentPosition == -1){
      return;
    }
    var subString = newValue.text.substring(0,currentPosition);
    var lastPart = subString.split(" ").last.split("\n").last;
    var startIndex = currentPosition - lastPart.length;
    var detectionContent = newValue.text.substring(startIndex).split(" ").first.split("\n").first;
    print("[$startIndex, ${startIndex + detectionContent.length-1}] lastPath: [$detectionContent]");
    _detectionStream.add(SocialContentDetection(getType(detectionContent), TextRange(start: startIndex, end: startIndex + detectionContent.length-1), detectionContent));
  }
  
  DetectedType getType(String word){
    return _regularExpressions.keys.firstWhere((type) => _regularExpressions[type]!.hasMatch(word),orElse: ()=>DetectedType.plain_text);
  }

  @override
  set value(TextEditingValue newValue) {
    _processNewValue(newValue);
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return SocialTextSpanBuilder(regularExpressions: _regularExpressions,defaultTextStyle: style,detectionTextStyles: detectionTextStyles).build(text);
  }
}