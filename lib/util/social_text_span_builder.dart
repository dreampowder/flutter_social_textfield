import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';

///Builds [TextSpan] with the provided regular expression, stles and text.
/// [defaultTextStyle] Optional default textstyle. used for detection types that has not been initialied
/// [detectionTextStyles] required, used for setting up text styles for types found in [DetectedType] enum
/// [regularExpressions] required, used for detecting [DetectedType] content. default regular expressions can be found in the plugin
class SocialTextSpanBuilder{

  final TextStyle? defaultTextStyle;
  final Map<DetectedType, TextStyle> detectionTextStyles;

  final Map<DetectedType, RegExp> regularExpressions;

  Map<DetectedType, List<RegExpMatch>?> allMatches = Map();

  SocialTextSpanBuilder(this.regularExpressions,this.defaultTextStyle,{this.detectionTextStyles = const {}});

  ///Gets Text Style for [start,end] range.
  ///return default text style if noting found.
  TextStyle getTextStyleForRange(int start, int end){
    TextStyle? textStyle;
    allMatches.keys.forEach((type) {
      var index = allMatches[type]!.indexWhere((match) => match.start == start && match.end == end);
      if(index != -1){
        textStyle = detectionTextStyles[type];
        return;
      }
    });
    return textStyle ?? defaultTextStyle ?? TextStyle();
  }

  ///returns TextSpan conaining all formatted content.
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
      var subString = text.substring(match.start, match.end);
      bool willAddSpaceAtStart = subString.startsWith(" "); //Strangely, mention and hashtags start with an empty space, while web detections are correct
      root = getTextSpan(root, text.substring(cursorPosition,match.start + (willAddSpaceAtStart ? 1 : 0)), getTextStyleForRange(cursorPosition, match.start));
      root = getTextSpan(root, text.substring(match.start+(willAddSpaceAtStart ? 1 : 0), match.end), getTextStyleForRange(match.start, match.end));
      cursorPosition = match.end;
    }
    if(cursorPosition < text.length-1){
      root = getTextSpan(root, text.substring(cursorPosition), getTextStyleForRange(cursorPosition, text.length));
    }
    return root;
  }

  ///Wraps text with style inside the root.
  ///[root] optional, return TextSpan(text, style:style) if null
  ///[style] TextStyle
  TextSpan getTextSpan(TextSpan? root, String text, TextStyle style){
    if(root == null){
      return TextSpan(text: text,style: style);
    }else{
      return TextSpan(children: [root, TextSpan(text: text, style: style)]);
    }
  }
}