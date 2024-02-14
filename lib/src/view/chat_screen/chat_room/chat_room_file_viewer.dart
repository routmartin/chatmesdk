import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_file_preview/flutter_file_preview.dart';

class FileViewScreen extends StatefulWidget {
  final String url;
  const FileViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<FileViewScreen> createState() => _FileViewScreenState();
}

class _FileViewScreenState extends State<FileViewScreen> {
  InAppWebViewController? webView;
  late String url;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    url = widget.url;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     // title: Text('InAppWebView Example'),
      //     ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(useOnDownloadStart: false),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },
                onLoadStart: (InAppWebViewController controller, Uri? _url) {
                  setState(() {
                    url = _url.toString();
                  });
                },
                onLoadStop: (InAppWebViewController controller, Uri? _url) async {
                  setState(() {
                    url = _url.toString();
                  });
                },
                onProgressChanged: (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
