import 'dart:async';
import 'dart:collection';

import 'package:hn_app/src/article.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

enum StoriesType { topStories, newStories }

class HackerNewsBloc {
  HashMap<int, Article> _cachedArticles;
  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  final _isLoadingSubject = BehaviorSubject<bool>();
  Stream<bool> get isLoading => _isLoadingSubject.stream;

  var _articles = <Article>[];

  final _storiesTypeController = StreamController<StoriesType>();
  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  HackerNewsBloc() {
    _cachedArticles = HashMap<int, Article>();
    _initializeArticles(StoriesType.topStories);

    _storiesTypeController.stream.listen((storiesType) async {
      _getArticlesAndUpdate(await _getIds(storiesType));
    });
  }

  Future<void> _initializeArticles(StoriesType type) async {
    _getArticlesAndUpdate(await _getIds(type));
  }

  void close() {
    _storiesTypeController.close();
  }

  static const String _baseUrl = 'https://hacker-news.firebaseio.com/v0/';

  Future<List<int>> _getIds(StoriesType type) async {
    final partUrl = type == StoriesType.newStories ? 'new' : 'top';
    final url = '$_baseUrl${partUrl}stories.json';
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw HackerNewsApiError('Could not fetch $type stories');
    }

    return parseTopStores(res.body).take(10).toList();
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
    if (!_cachedArticles.containsKey(id)) {
      final url = '${_baseUrl}item/$id.json';
      final res = await http.get(url);
      if (res.statusCode == 200) {
        _cachedArticles[id] = parseArticle(res.body);
      }else{
        throw new HackerNewsApiError('Could not fetch story with ID: $id');
      }
    }
    return _cachedArticles[id];
  }
}

class HackerNewsApiError {
  final String message;
  HackerNewsApiError(this.message);
}
