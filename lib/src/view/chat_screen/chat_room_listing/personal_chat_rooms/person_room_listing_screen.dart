import 'package:flutter/material.dart';
import '../../../widget/no_network_widget.dart';
import 'person_room_listing_body.dart';

class PersonRoomListingScreen extends StatefulWidget {
  const PersonRoomListingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PersonRoomListingScreen> createState() => _PersonRoomListingScreen();
}

class _PersonRoomListingScreen extends State<PersonRoomListingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 14),
            NetworkConnectionTextWidget(),
            Expanded(child: PersonRoomListingBody()),
          ],
        ),
      ),
    );
  }
}
