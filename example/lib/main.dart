import 'dart:math';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
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
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return MouseRegion(
                    onEnter: (PointerEnterEvent event) {
                      showAlignedDialog(
                          context: context,
                          builder: _localDialogBuilder,
                          followerAnchor: Alignment.topLeft,
                          targetAnchor: Alignment.bottomLeft,
                          barrierColor: Colors.transparent);
                    },
                    child: Container(
                        width: 200,
                        height: 60,
                        color: Colors.orange,
                        child: Text("Hover to show a local dialog")),
                  );
                }),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showAlignedDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black87, width: 5)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 600,
                                    height: 360,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                "https://images.unsplash.com/photo-1612392062422-ef19b42f74df?ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2550&q=80"))),
                                  ),
                                  Container(
                                    width: 600,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text("Enlarged Image"),
                                    color: Colors.amberAccent,
                                    alignment: Alignment.center,
                                  )
                                ],
                              ),
                            );
                          },
                          followerAnchor: Alignment.topLeft,
                          targetAnchor: Alignment.bottomLeft,
                          barrierColor: Colors.transparent);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  "https://images.unsplash.com/photo-1612392062422-ef19b42f74df?ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2550&q=80"))),
                      alignment: Alignment.centerLeft,
                      width: 150,
                      height: 200,
                    ),
                  );
                }),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        showAlignedDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                insetPadding: EdgeInsets.zero,
                                title: Text("Alert!"),
                                content: Text("Its an alert"),
                              );
                            },
                            isGlobal: true,
                            followerAnchor: Alignment.center,
                            targetAnchor: Alignment.bottomLeft,
                            barrierColor: Colors.transparent);
                      },
                      child: Text("Tap to show a local alert dialog"));
                }),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        showGlobalDrawer(
                            context: context,
                            builder: _horizontalDrawerBuilder,
                            direction: AxisDirection.left);
                      },
                      child: Text("Tap to show a left drawer"));
                }),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        showGlobalDrawer(
                            context: context,
                            builder: _horizontalDrawerBuilder,
                            direction: AxisDirection.right);
                      },
                      child: Text("Tap to show a right drawer"));
                }),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        showGlobalDrawer(
                            context: context,
                            builder: _verticalDrawerBuilder,
                            direction: AxisDirection.up);
                      },
                      child: Text("Tap to show a top drawer"));
                }),
                SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        showGlobalDrawer(
                            context: context,
                            builder: _verticalDrawerBuilder,
                            direction: AxisDirection.down);
                      },
                      child: Text("Tap to show a bottom drawer"));
                }),
                SizedBox(
                  height: 20,
                ),
              ]
                ..add(Container(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      10,
                      (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Builder(builder: (context) {
                            return ElevatedButton(
                                onPressed: () {
                                  showAlignedDialog(
                                      context: context,
                                      builder: _localDialogBuilder,
                                      followerAnchor: Alignment.topLeft,
                                      targetAnchor: Alignment.bottomLeft,
                                      barrierColor: Colors.transparent,
                                      //offset: Offset(10, 10),
                                      avoidOverflow: true);
                                },
                                child: Text("Tap to show a local dialog"));
                          })),
                    ),
                  ),
                ))
                ..addAll(
                  List.generate(
                    5,
                    (index) => Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(builder: (context) {
                          var rng = new Random();
                          return ElevatedButton(
                              onPressed: () {
                                showAlignedDialog(
                                    context: context,
                                    builder: _localDialogBuilder,
                                    followerAnchor: Alignment.topLeft,
                                    targetAnchor: Alignment.bottomRight,
                                    barrierColor: Colors.transparent,
                                    avoidOverflow: true);
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: rng.nextInt(300) + 300,
                                  height: rng.nextInt(50) + 50,
                                  child: Text(
                                      "Tap to show a local dialog at bottom right")));
                        })),
                  ),
                )
                ..addAll(
                  List.generate(
                    15,
                    (index) => Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(8),
                        child: Builder(builder: (context) {
                          var rng = new Random();
                          return ElevatedButton(
                              onPressed: () {
                                showAlignedDialog(
                                    context: context,
                                    builder: _localDialogBuilder,
                                    followerAnchor: Alignment.bottomRight,
                                    targetAnchor: Alignment.topLeft,
                                    barrierColor: Colors.transparent,
                                    avoidOverflow: true);
                              },
                              child: Container(
                                  margin: EdgeInsets.all(
                                      rng.nextInt(100).toDouble()),
                                  alignment: Alignment.center,
                                  width: rng.nextInt(300) + 300,
                                  height: rng.nextInt(80) + 20,
                                  child: Text(
                                      "Tap to show a local dialog at top left")));
                        })),
                  ),
                ),
            ),
          ),
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

  WidgetBuilder get _horizontalDrawerBuilder {
    return (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Drawer(
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
        ),
      );
    };
  }

  WidgetBuilder get _verticalDrawerBuilder {
    return (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          height: 300,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.amberAccent,
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 18, color: Colors.black87),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
