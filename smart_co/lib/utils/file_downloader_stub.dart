// lib/utils/file_downloader_stub.dart
class FileDownloader {
  Future<void> downloadFile(List<int> pdfData, String filename) async {
    throw UnsupportedError('Cannot download files on this platform.');
  }
}
