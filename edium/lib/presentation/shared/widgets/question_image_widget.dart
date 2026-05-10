import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edium/core/config/api_config.dart';
import 'package:edium/services/louvre_service/louvre_service.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:flutter/material.dart';

part 'question_image_widget_image_shimmer.dart';
part 'question_image_widget_shimmer_painter.dart';
part 'question_image_widget_question_image_widget_state.dart';


const double _kMaxImageHeight = 280.0;
const double _kShimmerHeight = 180.0;


class QuestionImageWidget extends StatefulWidget {
  final String imageId;
  final bool dark;

  const QuestionImageWidget({super.key, required this.imageId, this.dark = false});

  @override
  State<QuestionImageWidget> createState() => _QuestionImageWidgetState();
}

