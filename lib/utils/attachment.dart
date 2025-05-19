import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';

String getAttachmentUrl(Fragment$FullAttachment attachment) {
  return "https://cabinet-api.sophia-dev.io/attachments/${attachment.uuid}/${attachment.name}${attachment.$extension}";
}

String getAttachmentThumbnailUrl(Fragment$FullAttachment attachment) {
  return "https://cabinet-api.sophia-dev.io/attachments/${attachment.uuid}/thumbnail";
}
