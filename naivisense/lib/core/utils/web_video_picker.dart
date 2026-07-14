import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

class WebVideoResult {
  final Uint8List bytes;
  final String name;

  WebVideoResult({required this.bytes, required this.name});
}

Future<WebVideoResult?> pickWebVideo() async {
  final completer = Completer<WebVideoResult?>();

  final input = html.FileUploadInputElement();

  input.accept = 'video/*';

  input.click();

  input.onChange.listen((event) {
    final files = input.files;

    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }

    final file = files.first;

    final reader = html.FileReader();

    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((event) {
      final bytes = Uint8List.fromList(reader.result as List<int>);

      completer.complete(WebVideoResult(bytes: bytes, name: file.name));
    });
  });

  return completer.future;
}
