import 'dart:math';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const String _imageUrl =
    'https://images.unsplash.com/photo-1612392062422-ef19b42f74df?ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2550&q=80';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                // The Builder provides the context of the button, so that the
                // dialog is aligned to the button.
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showAlignedDialog(
                        context: context,
                        builder: _localDialogBuilder,
                        followerAnchor: Alignment.topLeft,
                        targetAnchor: Alignment.bottomLeft,
                        barrierColor: Colors.transparent,
                      );
                    },
                    child: const Text('Tap to show a local dialog'),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return MouseRegion(
                    onEnter: (PointerEnterEvent event) {
                      showAlignedDialog(
                        context: context,
                        builder: _localDialogBuilder,
                        followerAnchor: Alignment.topLeft,
                        targetAnchor: Alignment.bottomLeft,
                        barrierColor: Colors.transparent,
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 60,
                      color: Colors.orange,
                      child: const Text('Hover to show a local dialog'),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showAlignedDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black87, width: 5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 600,
                                  height: 360,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(_imageUrl),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 600,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  color: Colors.amberAccent,
                                  alignment: Alignment.center,
                                  child: const Text('Enlarged Image'),
                                ),
                              ],
                            ),
                          );
                        },
                        followerAnchor: Alignment.topLeft,
                        targetAnchor: Alignment.bottomLeft,
                        barrierColor: Colors.transparent,
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_imageUrl),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      width: 150,
                      height: 200,
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showAlignedDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            insetPadding: EdgeInsets.zero,
                            title: Text('Alert!'),
                            content: Text('Its an alert'),
                          );
                        },
                        isGlobal: true,
                        followerAnchor: Alignment.center,
                        targetAnchor: Alignment.bottomLeft,
                        barrierColor: Colors.transparent,
                      );
                    },
                    child: const Text('Tap to show a global alert dialog'),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showGlobalDrawer(
                        context: context,
                        builder: _horizontalDrawerBuilder,
                        direction: AxisDirection.left,
                      );
                    },
                    child: const Text('Tap to show a left drawer'),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showGlobalDrawer(
                        context: context,
                        builder: _horizontalDrawerBuilder,
                        direction: AxisDirection.right,
                      );
                    },
                    child: const Text('Tap to show a right drawer'),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showGlobalDrawer(
                        context: context,
                        builder: _verticalDrawerBuilder,
                        direction: AxisDirection.up,
                      );
                    },
                    child: const Text('Tap to show a top drawer'),
                  );
                }),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showGlobalDrawer(
                        context: context,
                        builder: _verticalDrawerBuilder,
                        direction: AxisDirection.down,
                      );
                    },
                    child: const Text('Tap to show a bottom drawer'),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
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
                                avoidOverflow: true,
                              );
                            },
                            child: const Text('Tap to show a local dialog'),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                ...List.generate(
                  5,
                  (index) => Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(builder: (context) {
                      final rng = Random();
                      return ElevatedButton(
                        onPressed: () {
                          showAlignedDialog(
                            context: context,
                            builder: _localDialogBuilder,
                            followerAnchor: Alignment.topLeft,
                            targetAnchor: Alignment.bottomRight,
                            barrierColor: Colors.transparent,
                            avoidOverflow: true,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: rng.nextInt(300) + 300,
                          height: rng.nextInt(50) + 50,
                          child: const Text(
                            'Tap to show a local dialog at bottom right',
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                ...List.generate(
                  15,
                  (index) => Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(8),
                    child: Builder(builder: (context) {
                      final rng = Random();
                      return ElevatedButton(
                        onPressed: () {
                          showAlignedDialog(
                            context: context,
                            builder: _localDialogBuilder,
                            followerAnchor: Alignment.bottomRight,
                            targetAnchor: Alignment.topLeft,
                            barrierColor: Colors.transparent,
                            avoidOverflow: true,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(rng.nextInt(100).toDouble()),
                          alignment: Alignment.center,
                          width: rng.nextInt(300) + 300,
                          height: rng.nextInt(80) + 20,
                          child: const Text(
                            'Tap to show a local dialog at top left',
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  WidgetBuilder get _localDialogBuilder {
    return (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 18, color: Colors.black87),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tap to close'),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 4),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      debugPrint('hello2');
                    },
                    child: const Text('Tap to print'),
                  ),
                  const SizedBox(height: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
            ),
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Tap to close'),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 4),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        debugPrint('hello2');
                      },
                      child: const Text('Tap to print'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Some Text'),
                    const SizedBox(height: 10),
                    const Text('Some Text'),
                    const SizedBox(height: 10),
                    const Text('Some Text'),
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            color: Colors.amberAccent,
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 18, color: Colors.black87),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tap to close'),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 4),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      debugPrint('hello2');
                    },
                    child: const Text('Tap to print'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Some Text'),
                  const SizedBox(height: 10),
                  const Text('Some Text'),
                  const SizedBox(height: 10),
                  const Text('Some Text'),
                ],
              ),
            ),
          ),
        ),
      );
    };
  }
}
