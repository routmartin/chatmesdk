import 'dart:developer';
import 'package:flutter/material.dart';

import '../../../util/helper/crash_report.dart';

@protected
class BaseApiResponse<T> {
  final bool success;
  final List<dynamic>? error;
  final int? errorCode;
  final String? message;
  final Map<String, dynamic>? otherInfo;
  final T? result;
  const BaseApiResponse({
    this.otherInfo,
    this.success = true,
    this.errorCode,
    this.message,
    this.result,
    this.error,
  });

  // ignore: avoid_types_as_parameter_names
  static Map<String, dynamic> generateRequest(T) {
    return {'body': T.toMap()};
  }

  static BaseApiResponse<T> generateResponse<T>({
    required Map<String?, dynamic> response,
    required T Function(dynamic data) parseData,
  }) {
    try {
      if (response.containsKey('errorCode')) {
        int errorCode = response['errorCode'] as int;
        List<dynamic>? error = response['error'] as List<dynamic>?;
        String message = response['message'] ?? 'no message';
        Map<String, dynamic> otherInfo = {};
        for (var i in response.keys) {
          if (i != 'errorCode' || i != 'error' || i != 'message') {
            otherInfo[i ?? '-'] = response[i];
          }
        }

        return BaseApiResponse(
          success: false,
          message: message,
          error: error,
          errorCode: errorCode,
          otherInfo: otherInfo,
        );
      } else if (response.containsKey('data')) {
        return BaseApiResponse(
          success: true,
          result: parseData(response['data']),
        );
      } else {
        Map<String, dynamic> otherInfo = {};
        for (var i in response.keys) {
          if (i != 'errorCode' || i != 'error' || i != 'message') {
            otherInfo[i ?? '-'] = response[i];
          }
        }
        log('Base Response Error:  $response');
        return BaseApiResponse(otherInfo: otherInfo);
      }
    } catch (e) {
      final message = e.toString();
      CrashReport.send(ReportModel(message: '$message : response $response'));
      log(e.toString());
    }
    return BaseApiResponse<T>();
  }

  @override
  String toString() {
    return 'ApiBase(success: $success, error: $error, errorCode: $errorCode, message: $message, otherInfo: $otherInfo, result: $result)';
  }
}
