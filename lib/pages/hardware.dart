import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:repla_app/pages/hardware_qr.dart';
import 'package:repla_app/widgets/drawer.dart';

class HardwarePage extends StatefulWidget {
  const HardwarePage({Key? key}) : super(key: key);

  @override
  State<HardwarePage> createState() => _HardwarePageState();
}

class _HardwarePageState extends State<HardwarePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final flutterBlue = FlutterBlue.instance;

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  Barcode? prevBarcode;

  @override
  void initState() {
    super.initState();
    flutterBlue.startScan(timeout: Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('하드웨어 스캔'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ScanResult>>(
          stream: flutterBlue.scanResults,
          initialData: [],
          builder:
              (BuildContext context, AsyncSnapshot<List<ScanResult>> snapshot) {
            return RefreshIndicator(
                child: SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      children: snapshot.data!
                              .where((e) => e.device.name.isNotEmpty)
                              .map<Widget>((e) {
                            return SizedBox(
                              width: double.infinity,
                              child: Card(
                                  child: ListTile(
                                onTap: () async {
                                  await e.device.disconnect();
                                  await e.device.connect();

                                  final services =
                                      await e.device.discoverServices();

                                  for (var service in services) {
                                    if (service.uuid.toString().toLowerCase() !=
                                        '0000FFE0-0000-1000-8000-00805F9B34FB'
                                            .toLowerCase()) {
                                      continue;
                                    }
                                    var characteristics =
                                        service.characteristics;
                                    for (BluetoothCharacteristic c
                                        in characteristics) {
                                      await c.write(utf8.encode('CONNECTED\n'));
                                    }
                                  }

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HardwareQrScanPage(device: e.device)));
                                },
                                leading: Icon(Icons.devices),
                                title: Text(e.device.name),
                              )),
                            );
                          }).toList() +
                          [
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                  child: ListTile(
                                onTap: () async {
                                  final devices =
                                      await flutterBlue.connectedDevices;
                                  for (var e in devices) {
                                    e.disconnect();
                                  }
                                },
                                leading: Icon(Icons.delete),
                                title: Text('연결 해제'),
                              )),
                            ),
                          ],
                    ),
                  ),
                ),
                onRefresh: () async {
                  if (await flutterBlue.isScanning.first) return;
                  await flutterBlue.startScan(timeout: Duration(seconds: 4));
                });
          }),
      drawer: MainDrawer(parentContext: context),
    );
  }
}
