import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/controller/social_text_editing_controller.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';
import 'package:flutter_social_textfield/model/detected_type_enum.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BottomSheetControllerExampleScreen extends StatefulWidget {
  const BottomSheetControllerExampleScreen({Key key}) : super(key: key);

  @override
  _BottomSheetControllerExampleScreenState createState() => _BottomSheetControllerExampleScreenState();
}

class _BottomSheetControllerExampleScreenState extends State<BottomSheetControllerExampleScreen> {

  SocialTextEditingController _socialTextEditingController = SocialTextEditingController();
  StreamSubscription<SocialContentDetection> _streamSubscription;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isShowingModalBottomSheet = false;

  PanelController _panelController = PanelController();

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {

    _streamSubscription = _socialTextEditingController.subscribeToDetection(onDetectContent);
    _socialTextEditingController
      ..text = "Lorem ipsum @dolor sit amet, consectetur adipiscing elit, sed do eiusmod @tempor incididunt ut labore et dolore magna aliqua. Ut #tellus elementum sagittis vitae et. Id #velit ut tortor pretium viverra suspendisse. Massa placerat duis ultricies lacus sed. @Placerat in egestas erat imperdiet sed euismod nisi. Velit scelerisque in dictum non consectetur. Massa id neque aliquam vestibulum morbi blandit. Purus sit amet volutpat consequat mauris nunc congue nisi. Ut diam quam nulla porttitor massa id. Sed faucibus turpis in eu mi. Rhoncus mattis rhoncus urna neque. Vel eros donec ac odio. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Lobortis elementum nibh tellus molestie nunc non blandit massa enim. Amet consectetur adipiscing elit duis tristique @sollicitudin nibh sit amet.\nhttp://www.google.com"
      ..setTextStyle(DetectedType.mention, TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)))
      ..setTextStyle(DetectedType.url, TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
      ..setTextStyle(DetectedType.hashtag, TextStyle(color: Colors.blue, fontWeight: FontWeight.w600));

    super.initState();
  }

  void showMentionBottomSheet(){
    if(_panelController.isPanelClosed){
      _panelController.animatePanelToPosition(0.4);

    }
    // if(isShowingModalBottomSheet){
    //   return;
    // }
    // isShowingModalBottomSheet = true;
    // showModalBottomSheet(context: context, builder: (context){
    //   return SizedBox.expand(
    //     child: DraggableScrollableSheet(
    //       builder: (context,controller){
    //         return ListView.builder(
    //           controller: controller,
    //             itemBuilder: (context,index){
    //             return ListTile(
    //               title: Text("List Tile: $index"),
    //             );
    //           });
    //       },
    //     ),
    //   );
    // }).whenComplete(() => isShowingModalBottomSheet = false);
  }

  void onDetectContent(SocialContentDetection detection){
    if(detection.type == DetectedType.mention){
      showMentionBottomSheet();
    }else{
      if(_panelController.isPanelOpen){
        _panelController.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("BottomSheetController Example"),
      ),
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        minHeight: 0.0,
        controller: _panelController,
        panelBuilder: (scrollController){
          return ListView.builder(
            controller: scrollController,
              itemBuilder: (context,index){
                return ListTile(
                  title: Text("Title ${index}"),
                );
          });
        },
        body: Container(
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              TextField(
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                controller: _socialTextEditingController,
                expands: true,
                minLines: null,
                maxLines: null,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
