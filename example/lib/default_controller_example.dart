import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';

class DefaultControllerExampleScreen extends StatefulWidget {
  @override
  _DefaultControllerExampleScreenState createState() => _DefaultControllerExampleScreenState();
}

class _DefaultControllerExampleScreenState extends State<DefaultControllerExampleScreen> {
  SocialTextEditingController _textEditingController;
  TextRange lastDetectedRange;

  bool isSelectorOpen = false;
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  SocialContentDetection lastDetection;

  StreamSubscription<SocialContentDetection> _streamSubscription;

  @override
  void dispose() {
    _focusNode.dispose();
    _streamSubscription.cancel();
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = SocialTextEditingController()
      ..text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut tellus elementum sagittis vitae et. Id velit ut tortor pretium viverra suspendisse. Massa placerat duis ultricies lacus sed. Placerat in egestas erat imperdiet sed euismod nisi. Velit scelerisque in dictum non consectetur. Massa id neque aliquam vestibulum morbi blandit. Purus sit amet volutpat consequat mauris nunc congue nisi. Ut diam quam nulla porttitor massa id. Sed faucibus turpis in eu mi. Rhoncus mattis rhoncus urna neque. Vel eros donec ac odio. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Lobortis elementum nibh tellus molestie nunc non blandit massa enim. Amet consectetur adipiscing elit duis tristique sollicitudin nibh sit amet."
      ..setTextStyle(DetectedType.mention, TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)))
      ..setTextStyle(DetectedType.url, TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
      ..setTextStyle(DetectedType.hashtag, TextStyle(color: Colors.blue, fontWeight: FontWeight.w600));

    _streamSubscription = _textEditingController.subscribeToDetection(onDetectContent);
  }

  void onDetectContent(SocialContentDetection detection){
    lastDetection = detection;

  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.4;
    return Scaffold(
      appBar: AppBar(
        title: Text("DefaultSocialTextFieldController Example"),
      ),
      body: DefaultSocialTextFieldController(
        focusNode: _focusNode,
        scrollController: _scrollController,
        textEditingController: _textEditingController,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: TextField(
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  controller: _textEditingController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  decoration: InputDecoration(
                      hintText: "Please Enter a Text"
                  ),
                ),
              ),
            ],
          ),
        ),
        detectionBuilders: {
          DetectedType.mention:(context)=>mentionContent(height),
          DetectedType.hashtag:(context)=>hashtagContent(height),
          DetectedType.url:(context)=>urlContent(height)
        },
      ),
    );
  }

  PreferredSize mentionContent(double height){
    return PreferredSize(
      child: ListView.builder(itemBuilder: (context,index)=>
          ListTile(
            title: Text("@user_$index"),
            onTap: (){
              if(lastDetection != null){
                _textEditingController.replaceRange("@user_$index", lastDetection.range);
              }
            },
          )),
      preferredSize: Size.fromHeight(height),);
  }

  PreferredSize hashtagContent(double height){
    return PreferredSize(
      child: ListView.builder(itemBuilder: (context,index)=>
          ListTile(
            title: Text("#hashtag_$index"),
            onTap: (){
              if(lastDetection != null){
                _textEditingController.replaceRange("#hashtag_$index", lastDetection.range);
              }
            },
          )),
      preferredSize: Size.fromHeight(height),);
  }

  PreferredSize urlContent(double height){
    return PreferredSize(
      child: Container(
          alignment: Alignment.center,
          child: Text("A Website for url content")
      ),
      preferredSize: Size.fromHeight(height),);
  }
}
