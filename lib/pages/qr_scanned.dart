import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannedPage extends StatefulWidget {
  final Barcode barcode;
  final QRViewController controller;

  const QrScannedPage(
      {Key? key, required this.barcode, required this.controller})
      : super(key: key);

  @override
  State<QrScannedPage> createState() => _QrScannedPageState();
}

class _QrScannedPageState extends State<QrScannedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스캔 완료'),
        centerTitle: true,
      ),
      body: Text(widget.barcode.code),
    );
  }
}
