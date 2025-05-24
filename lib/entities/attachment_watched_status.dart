import 'package:objectbox/objectbox.dart';

@Entity()
class AttachmentWatchedStatus {
  @Id()
  int id = 0;
  String? attachmentId;
}
