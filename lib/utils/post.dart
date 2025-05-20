import 'package:flutter_html/flutter_html.dart';

import '../queries/thread.graphql.dart';

Map<int, String> generatePostNoToIdMap(List<Fragment$FullPost> posts) {
  final Map<int, String> postNoToId = {};
  for (var post in posts) {
    postNoToId[post.no] = post.id;
  }
  return postNoToId;
}

Map<String, List<String>> generateReplyMapFromPosts(
  List<Fragment$FullPost> posts,
) {
  final postNoToId = generatePostNoToIdMap(posts);
  final Map<String, List<String>> replies = {};
  for (var post in posts) {
    if (post.content == null) {
      continue;
    }

    final content = post.content!;
    final document = HtmlParser.parseHTML(content);
    final quoteAnchors = document.querySelectorAll('a[href^="#p"]');

    for (var anchor in quoteAnchors) {
      final href = anchor.attributes['href'];
      if (href == null) {
        continue;
      }

      final postNo = int.parse(href.substring(2));
      final postId = postNoToId[postNo];
      if (postId == null) {
        continue;
      }

      if (replies[postId] == null) {
        replies[postId] = [];
      }

      replies[postId]!.add(post.id);
    }
  }

  return replies;
}
