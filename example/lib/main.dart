import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/controller/social_text_editing_controller.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Social Text Field'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("DefaultSocialTextFieldController Example"),
            subtitle: Text("Editable Text field implementations"),
            trailing: Icon(Icons.chevron_right),
            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>ContentScreen())),
          ),
          ListTile(
            title: Text("SocialTextSpanBuilder Example"),
            subtitle: Text("For rendering detections inside RichTextField"),
            trailing: Icon(Icons.chevron_right),
            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>SocialTextSpanExampleScreen())),
          ),

        ],
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SocialTextSpanExampleScreen extends StatefulWidget {
  @override
  _SocialTextSpanExampleScreenState createState() => _SocialTextSpanExampleScreenState();
}

class _SocialTextSpanExampleScreenState extends State<SocialTextSpanExampleScreen> {

  String exampleContent = "Lorem ipsum @dolor sit amet, consectetur adipiscing elit, sed do eiusmod @tempor incididunt ut labore et dolore magna aliqua. Ut #tellus elementum sagittis vitae et. Id #velit ut tortor pretium viverra suspendisse. Massa placerat duis ultricies lacus sed. @Placerat in egestas erat imperdiet sed euismod nisi. Velit scelerisque in dictum non consectetur. Massa id neque aliquam vestibulum morbi blandit. Purus sit amet volutpat consequat mauris nunc congue nisi. Ut diam quam nulla porttitor massa id. Sed faucibus turpis in eu mi. Rhoncus mattis rhoncus urna neque. Vel eros donec ac odio. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Lobortis elementum nibh tellus molestie nunc non blandit massa enim. Amet consectetur adipiscing elit duis tristique @sollicitudin nibh sit amet.\nhttp://www.google.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SocialTextSpanBuilder"),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,8,0,16),
              child: Text("You can also use SocialTextSpanBuilder as a text formatter,and now it also supports click actions!",style: Theme.of(context).textTheme.headline5,),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,8,0,16),
              child: Text("Tap on a detection to see what happens!",style: Theme.of(context).textTheme.caption,),
            ),
            RichText(
              text: SocialTextSpanBuilder(
                  regularExpressions: {
                    DetectedType.mention:atSignRegExp,
                    DetectedType.hashtag: hashTagRegExp,
                    DetectedType.url: urlRegex
                  },
                  defaultTextStyle: TextStyle(color: Colors.black),
                  detectionTextStyles: {
                    DetectedType.mention:TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)),
                    DetectedType.hashtag: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    DetectedType.url: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)
                  },
                  onTapDetection: (detection){
                    print("Tapped Detection: $detection");
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        title: Text("Tapped on detectoin"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Type: ${detection.type}"),
                            Text("Range: ${detection.range}"),
                            Text("Content: ${detection.text}")
                          ],
                        ),
                      );
                    });
                }
              ).build(exampleContent),
            ),
          ],
        ),
      ),
    );
  }
}


class ContentScreen extends StatefulWidget {
  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
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
    return DefaultSocialTextFieldController(
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
