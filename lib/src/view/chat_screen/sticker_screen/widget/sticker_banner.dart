import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../util/text_style.dart';

class StickerBanner extends StatelessWidget {
  const StickerBanner({
    Key? key,
    required this.stickerName,
    required this.width,
    required this.thumbnail,
    this.height = 150,
  }) : super(key: key);

  final String stickerName;
  final double width;
  final double height;

  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    var color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color.withOpacity(0.9), boxShadow: [
        BoxShadow(
          color: color,
          offset: const Offset(.0, 1),
          blurRadius: .6,
        ),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CachedNetworkImage(
              imageUrl: thumbnail ?? '',
              errorWidget: (context, url, error) => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
          Flexible(
            child: Text(
              stickerName,
              style: AppTextStyle.h4Bold,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}
