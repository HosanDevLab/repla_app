import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:repla_app/pages/hardware.dart';
import 'package:repla_app/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/login.dart';

class MainDrawer extends StatefulWidget {
  final BuildContext parentContext;

  const MainDrawer({Key? key, required this.parentContext}) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(NetworkImage(user.photoURL ?? ''), context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 1,
            child: UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.photoURL ?? ''),
                backgroundColor: Colors.transparent,
              ),
              accountEmail: Text((user.email ?? '') + '\n'),
              accountName: Text(user.displayName ?? ''),
              decoration: BoxDecoration(
                color: Colors.pink[400],
              ),
            )),
        Expanded(
          flex: 2,
          child: ListView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.zero,
            children: [
              Divider(height: 0),
              ListTile(
                title: Text('??????'),
                dense: true,
                leading: Icon(Icons.home),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(widget.parentContext,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              Divider(height: 0),
              ListTile(
                title: Text('????????????', style: TextStyle(color: Colors.red)),
                dense: true,
                leading: Icon(Icons.logout, color: Colors.red),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('????????????'),
                          content: Text('??????????????????????'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('????????????'),
                              onPressed: () async {
                                Navigator.pop(context);
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                        fullscreenDialog: true));
                              },
                            ),
                            TextButton(
                              child: Text('??????'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
              Divider(height: 0),
              ListTile(
                title: Text('???????????? ???????????????'),
                dense: true,
                leading: Icon(Icons.memory),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HardwarePage()));
                },
              ),
              Divider(height: 0),
              Divider(height: 0),
              ListTile(
                title: Text('??????'),
                dense: true,
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Divider(height: 0),
              ListTile(
                title: Text('????????? ??? ??????'),
                dense: true,
                leading: Icon(Icons.info),
                onTap: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  showAboutDialog(
                      context: context,
                      applicationName: packageInfo.appName,
                      applicationIcon: Image.asset('assets/repla.png',
                          width: 70, height: 70),
                      applicationVersion: packageInfo.version,
                      applicationLegalese: '???3??? SW ?????? ?????? ????????? ?????????',
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              text: '???/?????? ??????: ',
                            ),
                            TextSpan(
                              style: TextStyle(color: Colors.black),
                              text: '????????? ',
                            ),
                            TextSpan(
                              style: TextStyle(color: Colors.blue),
                              text: '(21181@hosan.hs.kr)',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launch('mailto:21181@hosan.hs.kr');
                                },
                            ),
                            TextSpan(
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              text: '\n???????????? ??????/??????: ',
                            ),
                            TextSpan(
                              style: TextStyle(color: Colors.black),
                              text: '??????, ?????????',
                            ),
                          ])),
                        ),
                      ]);
                },
              ),
            ],
          ),
        )
      ],
    ));
  }
}
