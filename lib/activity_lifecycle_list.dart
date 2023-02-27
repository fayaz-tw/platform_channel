import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    home: ActivityLifeCycleList(),
  ));
}

class ActivityLifeCycleList extends StatefulWidget {
  const ActivityLifeCycleList({Key? key}) : super(key: key);

  @override
  State<ActivityLifeCycleList> createState() => _ActivityLifeCycleListState();
}

class _ActivityLifeCycleListState extends State<ActivityLifeCycleList> {
  static const MethodChannel _channel = MethodChannel('live_updates');

  final List<String> _lifecycleEvents = [];

  Future<void> initPlatformState() async {
    _channel.setMethodCallHandler((MethodCall call) async {
      debugPrint("${call.method} ${call.arguments}");
      if (call.method == 'update') {
        setState(() {
          _lifecycleEvents.add(call.arguments.toString());
        });
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
      appBar: AppBar(title: const Text("Live updates as list")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Platform.isAndroid) {
            _openLinkInGoogleChrome();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _lifecycleEvents.length,
        itemBuilder: (c, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _lifecycleEvents[i],
              style: const TextStyle(fontSize: 16.0),
            ),
          );
        },
      ),
    );
  }
}
