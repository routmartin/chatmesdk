import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;

class CacheManagerHelper {
  static const key = 'chatmeCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 2),
      maxNrOfCacheObjects: 50,
      fileService: CustomHttpFileService(),
      repo: JsonCacheInfoRepository(databaseName: key),
    ),
  );

  static void downloadFileToCacheManager(dio.CancelToken cancelToken, String url,
      {Function(int percentage)? onDownloadChange}) async {
    var response = await dio.Dio().get(
      url,
      options: dio.Options(responseType: dio.ResponseType.bytes),
      onReceiveProgress: (received, total) {
        if (onDownloadChange != null) {
          onDownloadChange(
            int.parse(
              (received / total * 100).toStringAsFixed(0),
            ),
          );
        }
      },
      cancelToken: cancelToken, // to cancel download progress
    );
    final extension = path.extension(url).substring(1); // substring to remove dot (.)
    await instance.putFile(url, Uint8List.fromList(response.data), fileExtension: extension);
  }
}

class CustomHttpFileService extends FileService {
  final http.Client _httpClient;

  CustomHttpFileService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final req = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      req.headers.addAll(headers);
    }
    // req.headers[HttpHeaders.acceptHeader] = 'video/3gpp';
    var httpResponse = await _httpClient.send(req);
    print('httpResponse ${lookupMimeType(url)} ${httpResponse.headers['content-type']}');
    httpResponse.headers['content-type'] = lookupMimeType(url)!;
    return HttpGetResponse(httpResponse);
  }
}
