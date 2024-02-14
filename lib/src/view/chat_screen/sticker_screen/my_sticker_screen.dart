import 'package:chatmesdk/src/view/widget/appbar.dart';

import '../../../util/constant/app_assets.dart';
import '../../widget/scaffold_wrapper.dart';
import 'export.dart';

class MyStickerScreen extends StatefulWidget {
  const MyStickerScreen({Key? key}) : super(key: key);

  @override
  State<MyStickerScreen> createState() => _MyStickerScreenState();
}

class _MyStickerScreenState extends State<MyStickerScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StickerController>(builder: (controller) {
      return ScaffoldWrapper(
        color: Colors.white,
        padding: 16,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShareAppbar(title: FontUtil.tr('my_stickers')),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE1E2E6),
                    width: 0.33,
                  ),
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: searchController,
                  autofocus: false,
                  onChanged: (value) {
                    controller.searchMySticker(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.fromLTRB(0, 14, 12, 0),
                    suffixIcon: Offstage(
                      offstage: searchController.text.isEmpty,
                      child: InkWell(
                        onTap: () {
                          searchController.clear();
                          controller.searchMySticker('');
                        },
                        child: const Icon(Icons.cancel, color: Colors.grey),
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'search_stickers'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    ...List.generate(
                      controller.myStickerAfterSearch?.length ?? 0,
                      (stickerIndex) {
                        var sticker = controller.myStickerAfterSearch?[stickerIndex];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => navigateToStickerDetailScreen(
                                  sticker?.stickergroupId ?? '',
                                ),
                                child: Container(
                                    width: 80,
                                    height: 80,
                                    padding: const EdgeInsets.all(8),
                                    color: const Color(0xffd6d6d6),
                                    child: CachedNetworkImage(
                                        imageUrl: sticker?.thumbnail ?? '',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => Image.asset(
                                              Assets.app_assetsIconsMyPofileAvatar,
                                              width: 20,
                                              height: 20,
                                              fit: BoxFit.cover,
                                            ))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => navigateToStickerDetailScreen(
                                    sticker?.stickergroupId ?? '',
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ChatHelper.stickerNameAndDescription(sticker?.name),
                                        style: AppTextStyle.normalBold,
                                      ),
                                      Text(ChatHelper.stickerNameAndDescription(sticker?.description ?? ''),
                                          style: AppTextStyle.smallTextMediumGrey),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: (() => removeStickerFromMySticker(
                                      controller,
                                      sticker?.stickergroupId ?? '',
                                    )),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffCD2525),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'remove'.tr,
                                    style: const TextStyle(
                                      fontSize: 11.33,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void removeStickerFromMySticker(
    StickerController controller,
    String? groupId,
  ) {
    if (groupId == null) return;
    controller.removeSticker(groupId);
  }

  void navigateToStickerDetailScreen(String groupId) {
    Get.to(() => StickerDetailScreen(groupId: groupId));
  }
}
