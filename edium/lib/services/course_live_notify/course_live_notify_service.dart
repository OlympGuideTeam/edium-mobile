import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:edium/core/config/api_config.dart';
import 'package:flutter/foundation.dart';

part 'course_live_notify_service_course_live_notify_service.dart';


class CourseLiveItem {
  final String sessionId;
  final String courseId;
  final String quizTitle;
  final int questionTimeLimitSec;

  const CourseLiveItem({
    required this.sessionId,
    required this.courseId,
    required this.quizTitle,
    required this.questionTimeLimitSec,
  });

  factory CourseLiveItem.fromJson(Map<String, dynamic> json) => CourseLiveItem(
        sessionId: json['session_id'] as String,
        courseId: json['course_id'] as String? ?? '',
        quizTitle: json['quiz_title'] as String? ?? '',
        questionTimeLimitSec:
            (json['question_time_limit_sec'] as num?)?.toInt() ?? 30,
      );
}

