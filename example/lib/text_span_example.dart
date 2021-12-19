import 'package:flutter/material.dart';
import 'package:flutter_social_textfield/flutter_social_textfield.dart';

class SocialTextSpanExampleScreen extends StatefulWidget {
  @override
  _SocialTextSpanExampleScreenState createState() => _SocialTextSpanExampleScreenState();
}

class _SocialTextSpanExampleScreenState extends State<SocialTextSpanExampleScreen> {

  String exampleContent = "Lorem ipsum @dolor sit amet, consectetur adipiscing elit,sed do eiusmod @tempor incididunt ut labore email@ma et dolore magna aliqua. Ut #tellus elementum sagittis vitae et. Id #velit ut tortor pretium viverra suspendisse. Massa placerat duis ultricies lacus sed. @Placerat in egestas erat imperdiet sed euismod nisi. Velit scelerisque in dictum non consectetur. Massa id neque aliquam vestibulum morbi blandit. Purus sit amet volutpat consequat mauris nunc congue nisi. Ut diam quam nulla porttitor massa id. Sed faucibus turpis in eu mi. Rhoncus mattis rhoncus urna neque. Vel eros donec ac odio. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Lobortis elementum nibh tellus molestie nunc non blandit massa enim. Amet consectetur adipiscing elit duis tristique @sollicitudin nibh sit amet.\nhttp://www.google.com\n\https://bhupesh-v.github.io/ \n";

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
                    DetectedType.url: urlRegex,
                  },
                  defaultTextStyle: TextStyle(color: Colors.black),
                  detectionTextStyles: {
                    DetectedType.mention:TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)),
                    DetectedType.hashtag: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    DetectedType.url: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                  },
                  onTapDetection: (detection){
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
              // ).build(exampleContent,ignoreCases: ["@dolor"]),
              // ).build(exampleContent,includeOnlyCases: ["@dolor"]),
            ),
          ],
        ),
      ),
    );
  }
}


