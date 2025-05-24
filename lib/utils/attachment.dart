import 'package:cabinet/queries/thread.graphql.dart';
import 'package:cabinet/queries/watcherThreads.graphql.dart';

String getAttachmentUrl(Fragment$FullAttachment attachment) {
  return "https://cabinet-api.sophia-dev.io/attachments/${attachment.uuid}/${Uri.encodeComponent(attachment.name)}${attachment.$extension}";
}

String getAttachmentThumbnailUrl(Fragment$FullAttachment attachment) {
  return "https://cabinet-api.sophia-dev.io/attachments/${attachment.uuid}/thumbnail";
}

int getAttachmentIndex(
  List<Fragment$FullPost> posts,
  Fragment$FullAttachment attachment,
  Fragment$FullPost post,
) {
  final allPosts = posts;
  int startIndex = 0;
  for (var i = 0; i < allPosts.length; i++) {
    if (allPosts[i].id == post.id) {
      break;
    }

    startIndex += allPosts[i].attachments?.length ?? 0;
  }

  final targetPost = allPosts.firstWhere((p) => p.id == post.id);
  if (targetPost.attachments == null || targetPost.attachments == null) {
    throw Exception("No attachments available");
  }

  final attachmentIndex = targetPost.attachments!.indexWhere(
    (a) => a.id == attachment.id,
  );
  if (attachmentIndex == -1) {
    throw Exception("Attachment not found");
  }

  return startIndex + attachmentIndex;
}
