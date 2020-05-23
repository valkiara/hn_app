import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'dart:convert' as json;

import 'package:built_value/serializer.dart';
import 'serializers.dart';

part 'article.g.dart';


abstract class Article implements Built<Article, ArticleBuilder> {
  static Serializer<Article> get serializer => _$articleSerializer;

  int get id; //	The item's unique id.

  @nullable
  bool get deleted; //	true if the item is deleted.

  String
      get type; //	The type of item. One of "job", "story", "comment", "poll", or "pollopt".
  String get by; //	The username of the item's author.
  int get time; //	Creation date of the item, in Unix Time.

  @nullable
  String get text; //	The comment, story or poll text. HTML.

  @nullable
  bool get dead; //	true if the item is dead.

  @nullable
  int get parent; //	The comment's parent: either another comment or the relevant story.

  @nullable
  int get poll; //	The pollopt's associated poll.

  BuiltList<int>
      get kids; //	The ids of the item's comments, in ranked display order.

  @nullable
  String get url; //	The URL of the story.

  @nullable
  int get score; //	The story's score, or the votes for a pollopt.

  @nullable
  String get title; //	The title of the story, poll or job. HTML.

  BuiltList<int> get parts; //	A list of related pollopts, in display order.

  @nullable
  int get descendants; //	In the case of stories or polls, the total comment count.

  Article._();
  factory Article([updates(ArticleBuilder b)]) = _$Article;
}


List<int> parseTopStores(String jsonStr) {
  return List<int>.from(json.jsonDecode(jsonStr));
}

Article parseArticle(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  Article article =
      standardSerializers.deserializeWith(Article.serializer, parsed);
  return article;
}
