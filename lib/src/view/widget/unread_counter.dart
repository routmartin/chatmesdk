import 'package:flutter/material.dart';

class UnReadCountWidget extends StatelessWidget {
  final int amount;
  final bool isMute;
  const UnReadCountWidget({Key? key, required this.amount, required this.isMute}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var smallRadius = 10.0;
    var bigRadius = 10.2;
    return amount > 0
        ? CircleAvatar(
            backgroundColor: isMute ? Colors.grey : const Color(0xffCD2525),
            radius: amount < 100 ? smallRadius : bigRadius,
            child: Text(
              amount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          )
        : const Offstage();
  }
}
