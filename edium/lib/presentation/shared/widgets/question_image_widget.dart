import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edium/core/config/api_config.dart';
import 'package:edium/services/louvre_service/louvre_service.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:flutter/material.dart';

const double _kMaxImageHeight = 280.0;
const double _kShimmerHeight = 180.0;

/// Отображает изображение вопроса по его UUID из сервиса Louvre.
/// [dark] — тёмный фон (для live-экранов).
class QuestionImageWidget extends StatefulWidget {
  final String imageId;
  final bool dark;

  const QuestionImageWidget({super.key, required this.imageId, this.dark = false});

  @override
  State<QuestionImageWidget> createState() => _QuestionImageWidgetState();
}

class _ImageShimmer extends StatefulWidget {
  final bool dark;
  const _ImageShimmer({this.dark = false});

  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _anim = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.dark ? const Color(0xFF1A1A2A) : const Color(0xFFE8E8E8);
    final highlight = widget.dark ? const Color(0xFF3A3A5A) : const Color(0xFFFFFFFF);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: _kShimmerHeight,
          child: CustomPaint(
            painter: _ShimmerPainter(
              progress: _anim.value,
              base: base,
              highlight: highlight,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color base;
  final Color highlight;

  const _ShimmerPainter({
    required this.progress,
    required this.base,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Заливаем базовым цветом
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    // Узкая яркая полоса (~30% ширины) скользит от -30% до 130%
    const stripeFraction = 0.30;
    final stripeW = size.width * stripeFraction;
    final startX = -stripeW + (size.width + stripeW) * progress;

    final gradient = LinearGradient(
      colors: [
        base.withAlpha(0),
        highlight.withAlpha(230),
        base.withAlpha(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(startX, 0, stripeW, size.height));

    canvas.drawRect(
      Rect.fromLTWH(startX, 0, stripeW, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) =>
      old.progress != progress || old.base != base || old.highlight != highlight;
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
      return _ImageShimmer(dark: widget.dark);
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
