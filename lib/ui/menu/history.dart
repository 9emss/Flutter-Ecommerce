import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_mac/get_mac.dart';

class History extends StatefulWidget {
  History({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String _macAddress = 'Unknown';

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    initPlatformSatate();
  }

  Future<void> initPlatformSatate() async {
    String macAddress;

    try {
      macAddress = await GetMac.macAddress;
    } on PlatformException {
      macAddress = 'Failed to get Mac Address';
    }

    if (!mounted) return;

    setState(() {
      _macAddress = macAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("MAC : " + _macAddress),
        ),
      ),
    );
  }
}
