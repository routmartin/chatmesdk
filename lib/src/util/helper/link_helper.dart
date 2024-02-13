import 'package:http/http.dart' as http;

class LinkHelper {
  static Future<bool> isDownloadable(String url) async {
    final response = await http.head(Uri.parse(url));
    var bytes = int.parse(response.headers['content-length'] ?? '0');
    var mb = bytes / (1024 * 1024);
    return mb > 10; // if link response site bigger than 10 mb , considerBigfile
  }
}
