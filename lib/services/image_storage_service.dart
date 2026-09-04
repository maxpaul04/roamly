import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Future<String> saveImage(File pickedImage) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final fileName = basename(pickedImage.path);
    final savedPath =  '${documentDirectory.path}/$fileName';
    await pickedImage.copy(savedPath);
    return savedPath;
  }
}