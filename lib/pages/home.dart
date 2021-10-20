import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repla_app/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DoubleBack(
        message: '뒤로가기를 한번 더 누르면 종료합니다.',
        child: Scaffold(
          appBar: AppBar(
            title: Text('리플라 메인'),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Card(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [Text('내 리플캐시')],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text('3000P', style: TextStyle(fontSize: 36))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: '새로 등록하기',
            child: Icon(Icons.add),
          ),
          drawer: MainDrawer(parentContext: context),
        ));
  }
}
