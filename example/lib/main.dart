import 'package:flutter/material.dart';
import 'package:chatmesdk/chatmesdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final openChatUrl = "http://open-core.chatme.com";
  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtZXJjaGFudElkIjoiNjQ5MTMyYmYzZjVjMmVhZTBhMWRlNmYyIiwidXNlcklkIjoiNjVjZGJjMDU3ZjZmNzkyZWI4M2NkNDVlIiwidG9rZW5JZCI6ImM2MjkyNzFlLWY2MTMtNDNkZS04ZDU3LTFlOTA1N2JjMmYyNCIsImlhdCI6MTcwODA3MzE2NSwiZXhwIjoxNzA4MDczNzY1fQ.2IvkLtSZ6DkpAJxd5wI0yWc20PvrXRQDCKBuVfUMJYI";

  @override
  void initState() {
    super.initState();
    Chatmesdk.initalizer(token, '65cdbb0eb0cb798a81c0777f', openChatUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Chatmesdk.navigateToChatList(context);
              },
              child: const Icon(Icons.list),
            ),
            TextButton(
              onPressed: () {
                Chatmesdk.navigateToChatroom('65cdbd347f6f792eb83cd4f5', context);
              },
              child: const Icon(Icons.ads_click),
            ),
          ],
        ),
      ),
    );
  }
}
