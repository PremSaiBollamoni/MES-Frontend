import 'dart:typed_data';

Future<void> downloadFileInBrowser(Uint8List bytes, String filename, String mimeType) async {
  throw UnsupportedError('Browser downloads are only available in the web app');
}
