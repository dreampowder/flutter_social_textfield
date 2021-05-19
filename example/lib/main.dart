import 'dart:async';
import 'dart:ui';

import 'package:example/bottom_sheet_example.dart';
import 'package:example/text_span_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/controller/social_text_editing_controller.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';

import 'default_controller_example.dart';

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
            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>DefaultControllerExampleScreen())),
          ),
          ListTile(
            title: Text("SocialTextSpanBuilder Bottom Sheet Example"),
            subtitle: Text("A Different Approach for default controller"),
            trailing: Icon(Icons.chevron_right),
            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>BottomSheetControllerExampleScreen())),
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

