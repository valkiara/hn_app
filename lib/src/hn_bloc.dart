import 'dart:collection';

import 'package:hn_app/src/article.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class HackerNewsBloc {

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  var _articles = <Article>[];
  
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;


  List<int> _ids = [
    23285249,
    23285466,
    23285845,
    23283880,
    23270289,
    23285593,
    23281542,
    23281634,
    23282207,
    23281278,
    23278405,
    23283527,
    23285664,
    23281564,
    23284987,
    23282209,
    23285608,
    23270269,
    23283675,
    23282754
  ];

  HackerNewsBloc() {
    _updateArticles().then((_) => {
      _articlesSubject.add(UnmodifiableListView(_articles))
    });
  }


  Future<Null> _updateArticles() async {
    final futureArticles = _ids.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }

  Future<Article> _getArticle(int id) async {
    final url = 'https://hacker-news.firebaseio.com/v0/item/$id.json';

    final res = await http.get(url);
    if (res.statusCode == 200) {
      return parseArticle(res.body);
    } else {
      return null;
    }
  }
}
