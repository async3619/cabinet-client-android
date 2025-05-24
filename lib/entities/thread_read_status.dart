import 'package:objectbox/objectbox.dart';

@Entity()
class ThreadReadStatus {
  @Id()
  int id = 0;
  String? threadId;
}
