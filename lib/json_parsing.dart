import 'dart:convert' as json;
import 'package:built_value/built_value.dart';

part 'json_parsing.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
int get id;

  Article._();
  factory Article([updates(ArticleBuilder b)]) = _$Article;
}

List<int> parseTopStores(String jsonStr) {
  //return List<int>.from(json.jsonDecode(jsonStr));
  return [];
}

Article parseArticle(String json) {
  return null;
}
