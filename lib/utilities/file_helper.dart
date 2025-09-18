import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String?> downloadImage(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = "${dir.path}/$filename";

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath; // return local path
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
    return null;
  }
}
