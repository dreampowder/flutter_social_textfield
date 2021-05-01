import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/model/detected_type_enum.dart';
import 'package:flutter_social_textfield/model/social_content_detection_model.dart';

///Builds [TextSpan] with the provided regular expression, stles and text.
/// [defaultTextStyle] Optional default textstyle. used for detection types that has not been initialied
/// [detectionTextStyles] required, used for setting up text styles for types found in [DetectedType] enum
/// [regularExpressions] required, used for detecting [DetectedType] content. default regular expressions can be found in the plugin
/// [onTapDetection] optional. When set, it assings [TapGestureRecognizer] to formatted content. It returns [SocialContentDetection] as response
class SocialTextSpanBuilder{

  final Function(SocialContentDetection detection)? onTapDetection;
  final TextStyle? defaultTextStyle;
  final Map<DetectedType, TextStyle> detectionTextStyles;

  final Map<DetectedType, RegExp> regularExpressions;

  Map<DetectedType, List<RegExpMatch>?> allMatches = Map();

  SocialTextSpanBuilder({required this.regularExpressions,required this.defaultTextStyle,this.detectionTextStyles = const {},this.onTapDetection});

  ///Gets Text Style for [start,end] range.
  ///return default text style if noting found.
  MatchSearchResult getTextStyleForRange(int start, int end){

    TextStyle? textStyle;
    DetectedType detectedType = DetectedType.plain_text;
    String text = "";
    allMatches.keys.forEach((type) {
      var index = allMatches[type]!.indexWhere((match) => match.start == start && match.end == end);
      if(index != -1){
        textStyle = detectionTextStyles[type];
        detectedType = type;
        text = allMatches[type]![index].input.substring(start,end);
        return;
      }
    });
    return MatchSearchResult(textStyle ?? defaultTextStyle ?? TextStyle(), detectedType,text);
  }

  ///returns TextSpan containing all formatted content.
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
      var firstSearch = getTextStyleForRange(cursorPosition, match.start);
      root = getTextSpan(root, text.substring(cursorPosition,match.start + (willAddSpaceAtStart ? 1 : 0)), firstSearch.textStyle);

      var secondSearch = getTextStyleForRange(match.start, match.end);
      TapGestureRecognizer? tapRecognizer2;
      if(onTapDetection != null){
        tapRecognizer2 = TapGestureRecognizer()..onTap = (){
          onTapDetection!(SocialContentDetection(
            secondSearch.type,
            TextRange(start:match.start,end: match.end),
            secondSearch.text
          ));
        };
      }
      root = getTextSpan(root, text.substring(match.start+(willAddSpaceAtStart ? 1 : 0), match.end), secondSearch.textStyle,tapRecognizer: tapRecognizer2);
      cursorPosition = match.end;

    }
    if(cursorPosition < text.length-1){
      root = getTextSpan(root, text.substring(cursorPosition), getTextStyleForRange(cursorPosition, text.length).textStyle);
    }
    return root;
  }

  ///Wraps text with style inside the root.
  ///[root] optional, return TextSpan(text, style:style) if null
  ///[style] TextStyle
  TextSpan getTextSpan(TextSpan? root, String text, TextStyle style,{TapGestureRecognizer? tapRecognizer}){
    if(root == null){
      return TextSpan(text: text,style: style,recognizer: tapRecognizer);
    }else{
      return TextSpan(children: [root, TextSpan(text: text, style: style,recognizer: tapRecognizer)]);
    }
  }
}

///Used internally by SocialTextSpanBuilder
///[textStyle] matched textstyle, return default if no matches fonud
///[type] detected type. returns [DetectedType.plain_text] by default.
///[text] returns text within range. returns empty string if no matches found.
class MatchSearchResult{
  final TextStyle textStyle;
  final DetectedType type;
  final String text;
  MatchSearchResult(this.textStyle, this.type,this.text);
}