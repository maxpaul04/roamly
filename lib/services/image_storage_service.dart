import 'dart:io';
import 'package:flutter/cupertino.dart';
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

  Future<String> saveProfilePicture(File sourceFile, String uid) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${documentDirectory.path}/profile_pictures');

    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final savedPath = '${profileDir.path}/$uid.jpg';
    await sourceFile.copy(savedPath);

    // Bust Flutter's image cache so the new file is picked up immediately instead of showing the stale cached version at the same path.
    imageCache.evict(FileImage(File(savedPath)));

    return savedPath;
  }

  Future<void> deleteProfilePicture(String uid) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/profile_pictures/$uid.jpg');
    if (await file.exists()) {
      await file.delete();
    }
  }
}