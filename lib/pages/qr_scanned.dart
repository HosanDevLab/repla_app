import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:repla_app/pages/home.dart';

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
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    dynamic data;
    try {
      data = json.decode(widget.barcode.code);
    } on FormatException {
      data = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('스캔 완료'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 3,
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: Column(
                      children: (data != null && data['repla'] == true)
                          ? <Widget>[
                              Text('상품 정보', style: TextStyle(fontSize: 28)),
                              Text('유통 바코드: ${data['product_id']}'),
                              SizedBox(height: 20),
                              Text(data['name'],
                                  style: TextStyle(fontSize: 18)),
                            ]
                          : [
                              Text('상품 인식에 실패했습니다!'),
                              Text(
                                '올바른 리플라 QR코드인지 확인해주세요.',
                                style: Theme.of(context).textTheme.caption,
                              )
                            ],
                    ),
                  ),
                ),
              ),
            ),
            (data != null && data['repla'] == true)
                ? Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('위 상품을 등록하시겠습니까?'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            final prod = await firestore
                                .collection('products')
                                .where('uid', isEqualTo: data['uid'])
                                .get();
                            setState(() {
                              isRegistering = true;
                            });

                            await prod.docs.first.reference
                                .update({'owner': user.uid});

                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          },
                          label: Text(isRegistering ? '등록 중...' : '등록하기!'),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
