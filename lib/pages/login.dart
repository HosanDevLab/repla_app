import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:repla_app/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoggingIn = false;
  bool isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RePla 로그인'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(child: Container()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'RePla - 리플라',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('플라스틱 캐시백 시스템'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (isLoggingIn) return;
                    if (!isDisposed) {
                      setState(() {
                        isLoggingIn = true;
                      });
                    }

                    try {
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn().signOut();

                      final GoogleSignInAccount? googleSignInAccount =
                          await GoogleSignIn().signIn();
                      final GoogleSignInAuthentication
                          googleSignInAuthentication =
                          await googleSignInAccount!.authentication;

                      final AuthCredential credential =
                          GoogleAuthProvider.credential(
                        accessToken: googleSignInAuthentication.accessToken,
                        idToken: googleSignInAuthentication.idToken,
                      );

                      final signInData = await FirebaseAuth.instance
                          .signInWithCredential(credential);

                      CollectionReference users = firestore.collection('users');

                      DocumentSnapshot me =
                          await users.doc(signInData.user!.uid).get();

                      await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()));
                    } catch (e) {
                      rethrow;
                    } finally {
                      if (!isDisposed) {
                        setState(() {
                          isLoggingIn = false;
                        });
                      }
                    }
                  },
                  icon: Icon(Icons.login, size: 18),
                  label: Text(isLoggingIn ? "로그인 중..." : "구글 계정으로 로그인"),
                ),
              )
            ],
          ),
          Expanded(child: Container()),
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('개발 및 운영: HosanDevLab\n2021 강해 이승민 황부연',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption),
          )
        ]),
      ),
    );
  }
}
