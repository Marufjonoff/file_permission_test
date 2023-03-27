// lib/image_model.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Bu enum ilovaning umumiy holatini boshqaradi
enum ImageSection {
  noStoragePermission, // Ruxsat rad etildi, lekin abadiy emas
  noStoragePermissionPermanent, // Ruxsat abadiy rad etildi
  browseFiles, // UI fayllarni tanlash tugmachasini ko'rsatadi
  imageLoaded, // Fayl tanlandi va ekranda ko'rsatiladi
}


class ImageModel extends ChangeNotifier {
  ImageSection _imageSection = ImageSection.browseFiles;

  ImageSection get imageSection => _imageSection;

  set imageSection(ImageSection value) {
    if (value != _imageSection) {
      _imageSection = value;
      notifyListeners();
    }
  }

  // Biz tanlangan faylni ushbu o'zgaruvchida saqlaymiz
  File? file;

  /// Fayllarga ruxsat so'rang va mos ravishda UI yangilanadi
  Future<bool> requestFilePermission() async {
    PermissionStatus result;
    // Androidda biz saqlashga ruxsat so'rashimiz kerak,
    // iOS-da esa fotosuratlarga ruxsat
    if (Platform.isAndroid) {
      result = await Permission.storage.request();
    } else {
      result = await Permission.photos.request();
    }

    if (result.isGranted) {
      imageSection = ImageSection.browseFiles;
      return true;
    } else if (Platform.isIOS || result.isPermanentlyDenied) {
      imageSection = ImageSection.noStoragePermissionPermanent;
    } else {
      imageSection = ImageSection.noStoragePermission;
    }
    return false;
  }

  /// Fayl tanlash vositasini chaqiring
  Future<void> pickFile() async {
    final FilePickerResult? result =
    await FilePicker.platform.pickFiles(type: FileType.image);

    // UIni tanlangan fayl bilan yangilang, agar
    // u to'g'ri fayl yo'liga ega
    if (result != null &&
        result.files.isNotEmpty &&
        result.files.single.path != null) {
      file = File(result.files.single.path!);
      imageSection = ImageSection.imageLoaded;
    }
  }
}
