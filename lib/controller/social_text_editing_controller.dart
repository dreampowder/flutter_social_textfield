import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';

enum DetectedType{
  mention, hashtag, url, plain_text
}

class SocialContentDetection{
  final DetectedType type;
  final TextRange range;
  final String text;
  SocialContentDetection(this.type, this.range, this.text);

  @override
  String toString() {
    return 'SocialContentDetection{type: $type, range: $range, text: $text}';
  }
}

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

  void updateContent(String newValue, TextRange range){
    var willAddSpaceAtEnd = text.length <= range.end;
    var replacingText = "@$newValue${willAddSpaceAtEnd ? " " : ""}";
    var replacedText = text.replaceRange(range.start, range.end, replacingText);

    var newCursorPosition = range.start+replacingText.length + (willAddSpaceAtEnd ? 0 : 1);
    value = TextEditingValue(text: replacedText,selection: selection.copyWith(baseOffset: newCursorPosition, extentOffset:  newCursorPosition));
  }

  void _processNewValue(TextEditingValue newValue){
    var currentPosition = newValue.selection.baseOffset;
    if(currentPosition == -1){
      return;
    }
    var subString = newValue.text.substring(0,currentPosition);
    var lastPart = subString.split(" ").last;
    var startIndex = currentPosition - lastPart.length;
    var detectionContent = newValue.text.substring(startIndex).split(" ").first;
    print("detection content: $detectionContent");
    _detectionStream.add(SocialContentDetection(getType(detectionContent), TextRange(start: startIndex, end: startIndex + detectionContent.length), detectionContent));
  }
  
  DetectedType getType(String word){
    return _regularExpressions.keys.firstWhere((type) => _regularExpressions[type]!.hasMatch(word),orElse: ()=>DetectedType.plain_text);
  }

  @override
  set value(TextEditingValue newValue) {
    assert(
    !newValue.composing.isValid || newValue.isComposingRangeValid,
    'New TextEditingValue $newValue has an invalid non-empty composing range '
        '${newValue.composing}. It is recommended to use a valid composing range, '
        'even for readonly text fields',
    );
    _processNewValue(newValue);
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({TextStyle? style, required bool withComposing}) {
    return SocialTextSpanBuilder(detectionTextStyles, _regularExpressions,style).build(text);
  }


}

class SocialTextSpanBuilder{

  final TextStyle? defaultTextStyle;
  final Map<DetectedType, TextStyle>? detectionTextStyles;

  final Map<DetectedType, RegExp> regularExpressions;

  Map<DetectedType, List<RegExpMatch>?> allMatches = Map();

  SocialTextSpanBuilder(this.detectionTextStyles,this.regularExpressions,this.defaultTextStyle);

  TextStyle getTextStyleForRange(int start, int end){
    TextStyle? textStyle;
    allMatches.keys.forEach((type) {
      var index = allMatches[type]!.indexWhere((match) => match.start == start && match.end == end);
      if(index != -1){
        textStyle = detectionTextStyles?[type];
        return;
      }
    });
    return textStyle ?? defaultTextStyle ?? TextStyle();
  }

  TextSpan build(String text){
    regularExpressions.keys.forEach((type) {
      allMatches[type] = regularExpressions[type]!.allMatches(text).toList();
    });
    if(allMatches.isEmpty){
      return TextSpan(text: text,style: defaultTextStyle);
    }
    var orderedMatches = allMatches.values.expand((element) => element!.toList()).toList()
      ..sort((m1,m2)=>m1.start.compareTo(m2.start));
    if(orderedMatches.isEmpty){
      return TextSpan(text: text,style: defaultTextStyle);
    }
    TextSpan root = TextSpan();
    int cursorPosition = 0;
    for(int i = 0;i<orderedMatches.length;i++){
      var match = orderedMatches[i];
        root = getTextSpan(root, text.substring(cursorPosition,match.start), getTextStyleForRange(cursorPosition, match.start));
        root = getTextSpan(root, text.substring(match.start, match.end), getTextStyleForRange(match.start, match.end));
        cursorPosition = match.end;
    }
    if(cursorPosition < text.length-1){
      root = getTextSpan(root, text.substring(cursorPosition), getTextStyleForRange(cursorPosition, text.length));
    }
    return root;
  }

  TextSpan getTextSpan(TextSpan? root, String text, TextStyle style){
    if(root == null){
      return TextSpan(text: text,style: style);
    }else{
      return TextSpan(children: [root, TextSpan(text: text, style: style)]);
    }
  }
}