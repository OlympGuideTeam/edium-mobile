import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edium/core/config/api_config.dart';
import 'package:edium/services/louvre_service/louvre_service.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:flutter/material.dart';

const double _kMaxImageHeight = 280.0;

/// Отображает изображение вопроса по его UUID из сервиса Louvre.
/// [dark] — тёмный фон (для live-экранов).
class QuestionImageWidget extends StatefulWidget {
  final String imageId;
  final bool dark;

  const QuestionImageWidget({super.key, required this.imageId, this.dark = false});

  @override
  State<QuestionImageWidget> createState() => _QuestionImageWidgetState();
}

class _QuestionImageWidgetState extends State<QuestionImageWidget> {
  Uint8List? _bytes;
  double? _aspectRatio; // ширина / высота реального изображения
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    if (!ApiConfig.useMock) _loadImage();
  }

  @override
  void didUpdateWidget(covariant QuestionImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (ApiConfig.useMock) return;
    if (oldWidget.imageId != widget.imageId) {
      setState(() {
        _bytes = null;
        _aspectRatio = null;
        _loading = true;
        _error = false;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final bytes =
          await getIt<LouvreService>().getImageBytes(widget.imageId);

      // Получаем точные размеры декодированного изображения, чтобы
      // вычислить правильную высоту под доступную ширину без искажений.
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ratio = frame.image.width / frame.image.height;
      frame.image.dispose();
      codec.dispose();

      if (mounted) {
        setState(() {
          _bytes = bytes;
          _aspectRatio = ratio;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ApiConfig.useMock) return const SizedBox.shrink();

    if (_loading) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: widget.dark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.dark ? Colors.white38 : Colors.black26,
          ),
        ),
      );
    }

    if (_error || _bytes == null || _aspectRatio == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Высота по соотношению сторон реального изображения, но не больше максимума.
        final naturalHeight = availableWidth / _aspectRatio!;
        final displayHeight = naturalHeight.clamp(0.0, _kMaxImageHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: availableWidth,
            height: displayHeight,
            child: Image.memory(_bytes!, fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
