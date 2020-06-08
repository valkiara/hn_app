import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hn_app/src/article.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    if (await canLaunch(e.url)) {
                      await launch(e.url);
                      close(context, e);
                    }
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