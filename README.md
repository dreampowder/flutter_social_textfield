# flutter_social_textfield

![Overview](https://github.com/dreampowder/flutter_social_textfield/blob/main/readme_contents/overview.gif)


A Flutter plugin that helps detection of common social media contents.
The current position of the cursor is used for detecting content.
Current detection types are:

* HashTag (#): Texts start with #
* Mention (@): Text start with @ sign
* Web Links: Can detect web links

You can see the supported detection types from DetectedType enum

    enum DetectedType{
        mention, //By Default texts starting with @sign
        hashtag,  //By default, texts starting with #hashtag
        url, //By default texts starting with http://xxx.yyy or https://aaa.bbb 
        plain_text //Any other type falls into this.
    }

You can change the relevant regex for that type if you want, which has been mentioned in [Configuring the Text Editing Controller](#configuring-the-text-editing-controller) part.

## Getting Started

SocialTextField is basically an improved Text Editing Controller, so you can just assign text controller to any text editing widget that you want.

    _textEditingController = SocialTextEditingController();

    TextField(
        controller: _textEditingController,
        expands: true,
        maxLines: null,
        minLines: null,
        decoration: InputDecoration(
        hintText: "Please Enter a Text"
        ),
    )

## Configuring the Text Editing Controller

SocialTextEditingController can be configured by calling configuration methods.

There are 2 setter methods for this.

* setTextStyle: Change how detected content shown.

  setTextStyle(DetectedType.mention, TextStyle(...)

* setRegexp: Override the detection regexp

  setRegexp(DetectedType.url, RegExp("your_own_regex_fr_this_type"))

It is recommended to set these values on initialization;

    _textEditingController = SocialTextEditingController()
        ..setTextStyle(DetectedType.mention, TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)))
        ..setRegexp(DetectedType.url, RegExp("your_own_regex_fr_this_type"));

## Listening Content Detection Events

One of the main reasons that i want to create this plugin was that i needed to listen detection events from different widgets.
So flutter_social_textfield provides a stream for detections so you can subscribe and listen events when needed.

    StreamSubscription<SocialContentDetection> _streamSubscription;

    @override
    void initState() {
    super.initState();
    _textEditingController = SocialTextEditingController()
    ..text = "Lorem ipsum amet."
    ..setTextStyle(DetectedType.mention, TextStyle(color: Colors.purple,backgroundColor: Colors.purple.withAlpha(50)))
    ..setTextStyle(DetectedType.url, TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
    ..setTextStyle(DetectedType.hashtag, TextStyle(color: Colors.blue, fontWeight: FontWeight.w600));
    
    //Subscribe to events
     _streamSubscription = _textEditingController.subscribeToDetection(onDetectContent);
    }
    
    void onDetectContent(SocialContentDetection detection){
     print("Detected Contet: $detection");
    }

don't forget to unsubscribe on dispose.

    @override
    void dispose() {
        _detectionStream.close();
        super.dispose();
    }

The Stream Subscriptoin returns SocialContentDetection class:

    class SocialContentDetection{
        final DetectedType type; //mention, url, hashtag, plan_text
        final TextRange range; //range of detected content
        final String text; //detected content
        SocialContentDetection(this.type, this.range, this.text);
        
        @override
        String toString() {
            return 'SocialContentDetection{type: $type, range: $range, text: $text}';
        }
    }

## DefaultSocialTextFieldController

I've implemented an experimental widget for ease of use. DefaultSocialTextFieldController puts the main content inside a Stack and allows users to show relevant content when curser comes over a detected content
![DefaultSocialTextFieldController in action](https://github.com/dreampowder/flutter_social_textfield/blob/main/readme_contents/default_text_controller.gif)

### Using DefaultSocialTextFieldController
An example usage of the DefaultSocialTextFieldController can be seen in the example project.
The main goal is to provide an easy way to implement features that have been seen in most of the social media applications.

## SocialTextSpanBuilder

flutter_social_textfield uses SocialTextSpanBuilder for rendering the text inside the attached textfield.
So if you just want to show formatted text content instead of using inside an editor you can use it like this:


    void initBuilder(){
        final Map<DetectedType, RegExp> _regularExpressions = {
            DetectedType.mention:atSignRegExp,
            DetectedType.hashtag:hashTagRegExp,
            DetectedType.url:urlRegex
        };
    
        final Map<DetectedType, TextStyle> _detectionTextStyles = {
            DetectedType.mention:TextStyle(...)
        };
    
        final TextStyle _defaultTextStyle = TextStyle();
    
        final _textSpanBuilder = SocialTextSpanBuilder(_regularExpressions,_defaultTextStyle,detectionTextStyles: _detectionTextStyles);
    }

    //And you can return RichText content bu calling build(context) method afterwards.
    @override
        Widget build(BuildContext context) {
            var height = MediaQuery.of(context).size.height * 0.4;
            return Scaffold(
                appBar: AppBar(
                    title: Text(widget.title),
                ),
            body: Container(
               child:_textSpanBuilder.build(context)
            )// This trailing comma makes auto-formatting nicer for build methods.
        );  
    }   


# Acknowledgements

This widget's default regular expressions taken from this wonderful widget:

[detectable_text_field](https://pub.dev/packages/detectable_text_field)

