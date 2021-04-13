import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Builder(builder: (context) {
              return ElevatedButton(
                  onPressed: () {
                    showAlignedDialog(
                        context: context,
                        builder: _localDialogBuilder,
                        followerAnchor: Alignment.topLeft,
                        targetAnchor: Alignment.bottomLeft,
                        barrierColor: Colors.transparent);
                  },
                  child: Text("Tap to show a local dialog"));
            }),
            Builder(builder: (context) {
              return ElevatedButton(
                  onPressed: () {
                    showAlignedDialog(
                        context: context,
                        builder: _globalDialogBuilder,
                        followerAnchor: Alignment.topLeft,
                        isGlobal: true,
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child) {
                          return SlideTransition(
                            position:
                                Tween(begin: Offset(-1, 0), end: Offset(0, 0))
                                    .animate(animation),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              child: child,
                            ),
                          );
                        });
                  },
                  child: Text("Tap to show a left drawer"));
            }),
            Builder(builder: (context) {
              return ElevatedButton(
                  onPressed: () {
                    showAlignedDialog(
                        context: context,
                        builder: _globalDialogBuilder,
                        followerAnchor: Alignment.topRight,
                        isGlobal: true,
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child) {
                          return SlideTransition(
                            position:
                                Tween(begin: Offset(1, 0), end: Offset(0, 0))
                                    .animate(animation),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              child: child,
                            ),
                          );
                        });
                  },
                  child: Text("Tap to show a right drawer"));
            })
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  WidgetBuilder get _localDialogBuilder {
    return (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 18, color: Colors.black87),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Tap to close")),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 4,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        print("hello2");
                        //Navigator.of(context).pop();
                      },
                      child: Text("Tap to print")),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
  }

  WidgetBuilder get _globalDialogBuilder {
    return (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 400,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.amberAccent,
          ),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 18, color: Colors.black87),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Tap to close")),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 4,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        print("hello2");
                        //Navigator.of(context).pop();
                      },
                      child: Text("Tap to print")),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Some Text"),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Some Text"),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Some Text"),
                ],
              ),
            ),
          ),
        ),
      );
    };
  }
}
