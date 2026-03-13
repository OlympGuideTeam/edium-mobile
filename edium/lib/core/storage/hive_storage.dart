import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const String quizzesBoxName = 'quizzes';
  static const String profileBoxName = 'profile';
  static const String sessionsBoxName = 'sessions';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(quizzesBoxName);
    await Hive.openBox<String>(profileBoxName);
    await Hive.openBox<String>(sessionsBoxName);
  }

  static Box<String> get quizzesBox => Hive.box<String>(quizzesBoxName);
  static Box<String> get profileBox => Hive.box<String>(profileBoxName);
  static Box<String> get sessionsBox => Hive.box<String>(sessionsBoxName);
}
