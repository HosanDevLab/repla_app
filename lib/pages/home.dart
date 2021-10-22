import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repla_app/pages/scan.dart';
import 'package:repla_app/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  late Future<DocumentSnapshot<Map<String, dynamic>>> _user;
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _products;

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUser() async {
    return await firestore.collection('users').doc(user.uid).get();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchProducts() async {
    final data = await firestore
        .collection('products')
        .where('owner', isEqualTo: user.uid)
        .get();
    return data.docs;
  }

  @override
  void initState() {
    super.initState();
    _user = fetchUser();
    _products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBack(
        message: '뒤로가기를 한번 더 누르면 종료합니다.',
        child: Scaffold(
          appBar: AppBar(
            title: Text('리플라 메인'),
            centerTitle: true,
          ),
          body: FutureBuilder(
              future: Future.wait([_user, _products]),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        CircularProgressIndicator(color: Colors.pink),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text('불러오는 중', textAlign: TextAlign.center),
                        )
                      ]));
                }

                final user = snapshot.data[0].data();

                return RefreshIndicator(
                  child: SizedBox(
                    height: double.infinity,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Card(
                              color: Colors.pink[400],
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 16),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text('내 리플캐시',
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text('${user['point']}P',
                                              style: TextStyle(
                                                  fontSize: 36,
                                                  color: Colors.white))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(height: 20, thickness: 0.6),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 4),
                              child: Text('내가 구매한 플라스틱 제품',
                                  style: Theme.of(context).textTheme.headline6),
                            ),
                            snapshot.data[1].length > 0
                                ? Column(
                                    children: (snapshot.data[1] as List)
                                        .where((e) =>
                                            e.data()['isDeleted'] != true)
                                        .map((e) {
                                      final product = e.data();

                                      return Card(
                                        child: ListTile(
                                          onTap: () {},
                                          title: Text(product['name']),
                                          subtitle:
                                              Text('${product['price']}원'),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : Center(
                                    heightFactor: 3,
                                    child: Text(
                                      '구매한 플라스틱이 하나도 없습니다!',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                            Divider(height: 20, thickness: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onRefresh: () async {
                    final fetchUserFuture = fetchUser();
                    final fetchProductsFuture = fetchProducts();

                    setState(() {
                      _user = fetchUserFuture;
                      _products = fetchProductsFuture;
                    });
                    await Future.wait([_user, _products]);
                  },
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ScanPage()));
            },
            tooltip: '새로 등록하기',
            child: Icon(Icons.add),
          ),
          drawer: MainDrawer(parentContext: context),
        ));
  }
}
