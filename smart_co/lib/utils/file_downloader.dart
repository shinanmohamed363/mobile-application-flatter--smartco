// lib/utils/file_downloader.dart
export 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_mobile.dart';