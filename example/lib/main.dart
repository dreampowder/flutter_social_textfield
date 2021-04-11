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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  SocialTextEditingController _textEditingController;
  TextRange lastDetectedRange;

  bool isSelectorOpen = false;
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textEditingController = SocialTextEditingController()
      ..text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut tellus elementum sagittis vitae et. Id velit ut tortor pretium viverra suspendisse. Massa placerat duis ultricies lacus sed. Placerat in egestas erat imperdiet sed euismod nisi. Velit scelerisque in dictum non consectetur. Massa id neque aliquam vestibulum morbi blandit. Purus sit amet volutpat consequat mauris nunc congue nisi. Ut diam quam nulla porttitor massa id. Sed faucibus turpis in eu mi. Rhoncus mattis rhoncus urna neque. Vel eros donec ac odio. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Lobortis elementum nibh tellus molestie nunc non blandit massa enim. Amet consectetur adipiscing elit duis tristique sollicitudin nibh sit amet."
      ..setTextStyle(DetectedType.mention, TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)))
      ..setTextStyle(DetectedType.url, TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
      ..setTextStyle(DetectedType.hashtag, TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))
    ;
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.4;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.sync), onPressed: (){
            print("FocusNode: ${_focusNode.size}");

            _scrollController.animateTo(_focusNode.offset.dy + height, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
          })
        ],
      ),
      body: DefaultSocialTextFieldController(
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
        DetectedType.mention:(context)=>PreferredSize(
          child: ListView.builder(itemBuilder: (context,index)=>ListTile(title: Text("Item: $index"))),
          preferredSize: Size.fromHeight(height),)
      },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
