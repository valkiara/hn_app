import 'dart:async';
import 'dart:collection';

import 'package:hn_app/src/article.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

enum StoriesType { topStories, newStories }

class HackerNewsBloc {
  List<int> _newIds = [
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
  ];
  List<int> _topIds = [
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

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  final _isLoadingSubject = BehaviorSubject<bool>();
  Stream<bool> get isLoading => _isLoadingSubject.stream;

  var _articles = <Article>[];

  final _storiesTypeController = StreamController<StoriesType>();
  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  HackerNewsBloc() {
    _getArticlesAndUpdate(_topIds);

    _storiesTypeController.stream.listen((storiesType) {
      if (storiesType == StoriesType.newStories) {
        _getArticlesAndUpdate(_newIds);
      } else {
        _getArticlesAndUpdate(_topIds);
      }
    });
  }

  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }

  _getArticlesAndUpdate(List<int> ids) {
    _isLoadingSubject.add(true);
    _updateArticles(ids)
        .then((_) => {_articlesSubject.add(UnmodifiableListView(_articles))});

    _isLoadingSubject.add(false);
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
