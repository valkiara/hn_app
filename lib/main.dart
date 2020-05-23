import 'package:flutter/material.dart';
import 'package:hn_app/src/article.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Article> _aritcles = articles;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1));
            setState(() {
              _aritcles.removeAt(0);
            });
          },
          child: ListView(
            children: _aritcles.map(_buildItem).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Article e) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(
          e.text,
          style: TextStyle(fontSize: 24),
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text('${e.commentsCount} comments'),
              IconButton(
                icon: Icon(Icons.launch),
                onPressed: () async {
                  final fakeUrl = 'http://${e.domain}';

                  if (await canLaunch(fakeUrl)) {
                    launch(fakeUrl);
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
