// lib/utils/file_downloader_web.dart
import 'dart:html' as html;

class FileDownloader {
  Future<void> downloadFile(List<int> pdfData, String filename) async {
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url); // Cleanup the object URL
  }
}