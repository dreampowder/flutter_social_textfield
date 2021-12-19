import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/model/detected_type_enum.dart';
import 'package:flutter_social_textfield/model/social_content_detection_model.dart';

///Builds [TextSpan] with the provided regular expression, stles and text.
/// [defaultTextStyle] Optional default textstyle. used for detection types that has not been initialied
/// [detectionTextStyles] required, used for setting up text styles for types found in [DetectedType] enum
/// [regularExpressions] required, used for detecting [DetectedType] content. default regular expressions can be found in the plugin
/// [onTapDetection] optional. When set, it assings [TapGestureRecognizer] to formatted content. It returns [SocialContentDetection] as response
/// [ignoredTextStyle] optional. When set, content matched with "ignoreCases" of build function will return this text style, returns default text style if null.
class SocialTextSpanBuilder{

  final Function(SocialContentDetection detection)? onTapDetection;
  final TextStyle? defaultTextStyle;
  final TextStyle? ignoredTextStyle;
  final Map<DetectedType, TextStyle> detectionTextStyles;

  final Map<DetectedType, RegExp> regularExpressions;

  Map<DetectedType, List<RegExpMatch>?> allMatches = Map();

  SocialTextSpanBuilder({required this.regularExpressions,required this.defaultTextStyle,this.detectionTextStyles = const {},this.onTapDetection, this.ignoredTextStyle});

  ///Gets Text Style for [start,end] range.
  ///return TextStyle() style if nothing found.
  MatchSearchResult getTextStyleForRange(int start, int end, {List<String>? ignoreCases, List<String>? includeOnlyCases}){

    TextStyle? textStyle;
    DetectedType detectedType = DetectedType.plain_text;
    String text = "";
    allMatches.keys.forEach((type) {
      var index = allMatches[type]!.indexWhere((match) => match.start == start && match.end == end);

      if(index != -1){
        text = allMatches[type]![index].input.substring(start,end);
        var isIgnored = false;
        if(includeOnlyCases?.isNotEmpty ?? false){
          isIgnored = (includeOnlyCases?.indexWhere((t)=>t == text.trim()) ?? -1) == -1;
        }else{
          isIgnored = (ignoreCases?.indexWhere((t)=>t == text.trim()) ?? -1) >= 0;
        }
        if(isIgnored){
          textStyle = ignoredTextStyle;
          detectedType = DetectedType.plain_text;
        }else{
          textStyle = detectionTextStyles[type];
          detectedType = type;
        }
        return;
      }
    });
    return MatchSearchResult(textStyle ?? defaultTextStyle ?? TextStyle(), detectedType,text);
  }

  ///returns TextSpan containing all formatted content.
  ///[text] Text Content
  ///[ignoreCases] optional, when set, string values written in ignoreCases will be treated as Plain Text
  ///[includeOnlyCases] optional, when set, only values found in this array will be detected, other values be treated as Plain Text
  TextSpan build(String text, {List<String>? ignoreCases,List<String>? includeOnlyCases}){

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
      var firstSearch = getTextStyleForRange(cursorPosition, match.start,ignoreCases: ignoreCases,includeOnlyCases: includeOnlyCases);
      root = getTextSpan(root, text.substring(cursorPosition,match.start + (willAddSpaceAtStart ? 1 : 0)), firstSearch.textStyle);

      var secondSearch = getTextStyleForRange(match.start, match.end,ignoreCases: ignoreCases,includeOnlyCases: includeOnlyCases);
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
  ///[text] main content text
  ///[style] TextStyle
  ///[tapRecognizer] optional, tap action for detected content
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