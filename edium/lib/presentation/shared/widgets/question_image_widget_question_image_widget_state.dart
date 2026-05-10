part of 'question_image_widget.dart';

class _QuestionImageWidgetState extends State<QuestionImageWidget> {
  Uint8List? _bytes;
  double? _aspectRatio;
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

