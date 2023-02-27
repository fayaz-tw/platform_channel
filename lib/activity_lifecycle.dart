import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    home: ActivityLifeCycle(),
  ));
}

class ActivityLifeCycle extends StatefulWidget {
  const ActivityLifeCycle({Key? key}) : super(key: key);

  @override
  State<ActivityLifeCycle> createState() => _ActivityLifeCycleState();
}

class _ActivityLifeCycleState extends State<ActivityLifeCycle> {
  static const MethodChannel _channel = MethodChannel('live_updates');

  final StreamController<String> _updateStreamController = StreamController();

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> initPlatformState() async {
    _channel.setMethodCallHandler((MethodCall call) async {
      debugPrint("${call.method} ${call.arguments}");
      if (call.method == 'update') {
        _updateStreamController.sink.add(call.arguments);
      }
    });
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  void _openLinkInGoogleChrome() {
    final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.dev'),
        package: 'com.android.chrome');
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live updates")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _showMyDialog();
          if (Platform.isAndroid) {
            _openLinkInGoogleChrome();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<String>(
        stream: _updateStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(child: Text(snapshot.data!));
        },
      ),
    );
  }
}
