import 'package:objectbox/objectbox.dart';

@Entity()
class ThreadScrollPosition {
  @Id()
  int id = 0;
  String? threadId;
  double? scrollPosition;
}
