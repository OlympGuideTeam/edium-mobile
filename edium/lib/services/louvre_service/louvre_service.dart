import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class LouvreService {
  LouvreService(this._dioHandler);

  final DioHandler _dioHandler;


  static const int _maxCachedImageEntries = 48;

  final Map<String, Uint8List> _imageBytesCache = {};
  final Map<String, Future<Uint8List>> _imageBytesInFlight = {};

  Future<String> uploadImage(File file) async {
    final normalized = await _normalizeOrientation(file);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        normalized.path,
        filename: 'image.jpg',
      ),
    });
    final response = await _dioHandler.dio.post(
      'louvre/v1/images/upload',
      data: formData,
      options: Options(
        contentType: null,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    if (normalized.path != file.path) await normalized.delete();
    final data = response.data as Map<String, dynamic>;
    return data['id'] as String;
  }


  static Future<File> _normalizeOrientation(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return file;
    final Uint8List out = Uint8List.fromList(img.encodeJpg(decoded, quality: 88));
    final tmpDir = await getTemporaryDirectory();
    final tmp = File('${tmpDir.path}/louvre_upload_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tmp.writeAsBytes(out);
    return tmp;
  }

  String imageUrl(String imageId) =>
      '${_dioHandler.dio.options.baseUrl}louvre/v1/images/$imageId';


  Future<Uint8List> getImageBytes(String imageId) {
    final fromCache = _touchImageCache(imageId);
    if (fromCache != null) return Future<Uint8List>.value(fromCache);

    final inflight = _imageBytesInFlight[imageId];
    if (inflight != null) return inflight;

    final future = _downloadImageBytes(imageId);
    _imageBytesInFlight[imageId] = future;
    return future.whenComplete(() => _imageBytesInFlight.remove(imageId));
  }

  Uint8List? _touchImageCache(String imageId) {
    final bytes = _imageBytesCache.remove(imageId);
    if (bytes == null) return null;
    _imageBytesCache[imageId] = bytes;
    return bytes;
  }

  void _putImageCache(String imageId, Uint8List bytes) {
    _imageBytesCache.remove(imageId);
    _imageBytesCache[imageId] = bytes;
    while (_imageBytesCache.length > _maxCachedImageEntries) {
      _imageBytesCache.remove(_imageBytesCache.keys.first);
    }
  }

  Future<Uint8List> _downloadImageBytes(String imageId) async {
    final response = await _dioHandler.dio.get(
      'louvre/v1/images/$imageId',
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = Uint8List.fromList(response.data as List<int>);
    _putImageCache(imageId, bytes);
    return bytes;
  }
}
