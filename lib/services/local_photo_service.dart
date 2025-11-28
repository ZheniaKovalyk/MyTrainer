import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LocalPhotoService {
  Future<String> savePhoto(File pickedFile, String fileName) async {
    try {
      debugPrint('LocalPhotoService.savePhoto -> saving file: ${pickedFile.path} as $fileName');
      final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/$fileName';
      final savedFile = await pickedFile.copy(localPath);
      debugPrint('LocalPhotoService.savePhoto -> saved to: ${savedFile.path}');
      return savedFile.path;
    } catch (e, st) {
      debugPrint('LocalPhotoService.savePhoto ERROR: $e\n$st');
      rethrow;
    }
  }
}
