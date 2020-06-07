import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hn_app/src/article.dart';
import 'package:hn_app/src/hn_bloc.dart';
import 'package:hn_app/src/prefs_block.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  final hnBloc = HackerNewsBloc();
  final prefsBloc = PrefsBloc();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      hackerNewsBloc: hnBloc,
      prefsBloc: prefsBloc,
    ),
  );
}

class MyApp extends StatelessWidget {
  final HackerNewsBloc hackerNewsBloc;
  final PrefsBloc prefsBloc;

  static const primaryColor = Colors.white;

  MyApp({Key key, this.hackerNewsBloc, this.prefsBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: primaryColor,
        canvasColor: Colors.black,
        textTheme: Theme.of(context).textTheme.copyWith(
              caption: TextStyle(color: Colors.white54),
              subtitle1: TextStyle(
                fontFamily: 'Garamond',
                fontSize: 10.0,
              ),
            ),
      ),
      home: MyHomePage(
        title: 'Flutter Hacker News',
        hackerNewsBloc: hackerNewsBloc,
        prefsBloc: prefsBloc,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final HackerNewsBloc hackerNewsBloc;
  final PrefsBloc prefsBloc;

  MyHomePage({Key key, this.title, this.hackerNewsBloc, this.prefsBloc})
      : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: LoadingInfo(widget.hackerNewsBloc.isLoading),
        elevation: 0.0,
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  final Article result = await showSearch(
                    context: context,
                    delegate: ArticleSearch(_currentIndex == 0
                        ? widget.hackerNewsBloc.newArticles
                        : widget.hackerNewsBloc.topArticles),
                  );
                  // if (result != null && await canLaunch(result.url)) {
                  //   launch(result.url);
                  // }
                  if (result != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HackerNewsWebPage(
                          url: result.url,
                        ),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
      body: StreamBuilder<UnmodifiableListView<Article>>(
        stream: _currentIndex == 0
            ? widget.hackerNewsBloc.newArticles
            : widget.hackerNewsBloc.topArticles,
        initialData: UnmodifiableListView<Article>([]),
        builder: (context, snapshot) => ListView(
          children: snapshot.data.map(_buildItem).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              title: Text('Top Stories'), icon: Icon(Icons.trending_up)),
          BottomNavigationBarItem(
              title: Text('New Stores'), icon: Icon(Icons.new_releases)),
          BottomNavigationBarItem(
              title: Text('Settings'), icon: Icon(Icons.settings)),
        ],
        onTap: (index) {
          if (index == 0) {
            widget.hackerNewsBloc.storiesType.add(StoriesType.topStories);
          } else if (index == 1) {
            widget.hackerNewsBloc.storiesType.add(StoriesType.newStories);
          } else {
            _showPrefsSheet(context, widget.prefsBloc);
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key: PageStorageKey(article.title),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: ExpansionTile(
        title:
            Text(article.title ?? '[null]', style: TextStyle(fontSize: 24.0)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('${article.descendants} comments'),
                    SizedBox(width: 16.0),
                    IconButton(
                      icon: Icon(Icons.launch),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HackerNewsWebPage(
                              url: article.url,
                            ),
                          ),
                        );
                        // if (await canLaunch(article.url)) {
                        //   launch(article.url, forceWebView: false);
                        // }
                      },
                    )
                  ],
                ),
                StreamBuilder<PrefsState>(
                    stream: widget.prefsBloc.currentPrefs,
                    builder: (context, snapshot) {
                      if (snapshot.data?.showWebView == true) {
                        return Container(
                          height: 200,
                          child: WebView(
                            javascriptMode: JavascriptMode.unrestricted,
                            initialUrl: article.url,
                            gestureRecognizers: Set()
                              ..add(Factory<VerticalDragGestureRecognizer>(
                                  () => VerticalDragGestureRecognizer())),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrefsSheet(BuildContext context, PrefsBloc prefsBloc) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            body: Center(
              child: StreamBuilder<PrefsState>(
                stream: prefsBloc.currentPrefs,
                builder: (context, AsyncSnapshot<PrefsState> snapshot) {
                  return snapshot.hasData
                      ? Switch(
                          value: snapshot.data.showWebView,
                          onChanged: (value) => prefsBloc.showWebViewPref.add(value),
                        )
                      : Text('Nothing');
                },
              ),
            ),
          );
        });
  }
}

class LoadingInfo extends StatefulWidget {
  LoadingInfo(this._isLoading);

  final Stream<bool> _isLoading;

  @override
  _LoadingInfoState createState() => _LoadingInfoState();
}

class _LoadingInfoState extends State<LoadingInfo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget._isLoading,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        _controller.forward().then((value) => _controller.reverse());
        return FadeTransition(
          child: Icon(FontAwesomeIcons.hackerNewsSquare),
          opacity: Tween(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(curve: Curves.easeIn, parent: _controller),
          ),
        );
      },
    );
  }
}

class ArticleSearch extends SearchDelegate<Article> {
  final Stream<UnmodifiableListView<Article>> articles;

  ArticleSearch(this.articles);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Article>>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Data'),
          );
        }

        var results = snapshot.data.where((element) =>
            element.title.toLowerCase().contains(query.toLowerCase()));

        return ListView(
          children: results
              .map(
                (e) => ListTile(
                  title: Text(
                    e.title,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  leading: Icon(Icons.book),
                  onTap: () async {
                    // if (await canLaunch(e.url)) {
                    //   await launch(e.url);
                    //   close(context, e);
                    // }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HackerNewsWebPage(
                          url: e.url,
                        ),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        );
      },
      stream: articles,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Article>>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Data'),
          );
        }

        var results = snapshot.data.where((element) =>
            element.title.toLowerCase().contains(query.toLowerCase()));

        return ListView(
          children: results
              .map(
                (e) => ListTile(
                  title: Text(
                    e.title,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    close(context, e);
                  },
                ),
              )
              .toList(),
        );
      },
      stream: articles,
    );
  }
}

class HackerNewsWebPage extends StatelessWidget {
  final String url;

  HackerNewsWebPage({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HN APP'),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
