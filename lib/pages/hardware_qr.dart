import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:repla_app/widgets/drawer.dart';

class HardwareQrScanPage extends StatefulWidget {
  final BluetoothDevice device;

  const HardwareQrScanPage({Key? key, required this.device}) : super(key: key);

  @override
  State<HardwareQrScanPage> createState() => _HardwareQrScanPageState();
}

class _HardwareQrScanPageState extends State<HardwareQrScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final flutterBlue = FlutterBlue.instance;

  late QRViewController controller;

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  Barcode? prevBarcode;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('하드웨어 QR 스캔'),
        centerTitle: true,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) async {
            if (!listEquals(prevBarcode?.rawBytes, scanData.rawBytes)) {
              prevBarcode = scanData;
              controller.dispose();
              controller.pauseCamera();

              final services = await widget.device.discoverServices();

              for (var service in services) {
                if (service.uuid.toString().toLowerCase() !=
                    '0000FFE0-0000-1000-8000-00805F9B34FB'.toLowerCase()) {
                  continue;
                }
                var characteristics = service.characteristics;
                for (BluetoothCharacteristic c in characteristics) {
                  await c.write(utf8.encode('buzz'));
                }
              }

              dynamic data;
              try {
                data = json.decode(scanData.code);
              } on FormatException {
                data = null;
              }

              final prod = await firestore
                  .collection('products')
                  .where('uid', isEqualTo: data['uid'])
                  .get();

              await prod.docs
                  .where((e) => e.data()['isDeleted'] != true)
                  .first
                  .reference
                  .update({'isDeleted': true});

              firestore
                  .collection('users')
                  .doc(user.uid)
                  .update({'point': FieldValue.increment(100)});

              Future.delayed(Duration(seconds: 5), () {
                controller.resumeCamera();
              });
            }
          });
        },
      ),
      drawer: MainDrawer(parentContext: context),
    );
  }
}
