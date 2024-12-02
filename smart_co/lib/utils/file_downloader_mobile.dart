// lib/utils/file_downloader_mobile.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileDownloader {
  Future<void> downloadFile(List<int> pdfData, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(pdfData);
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error saving file: $e');
    }
  }
}
