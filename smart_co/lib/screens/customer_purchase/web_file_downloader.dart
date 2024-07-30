// import 'dart:html' as html;
// import 'dart:typed_data';

// class WebFileDownloader {
//   void downloadFile(Uint8List data, String fileName, String mimeType) {
//     final blob = html.Blob([data], mimeType);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute("download", fileName)
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   }
// }
