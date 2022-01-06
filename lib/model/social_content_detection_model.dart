import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/model/detected_type_enum.dart';

///Detection Content
///[type] [DetectedType]
///[range] Range of detection
///[text] substring content created by using [range] value.
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