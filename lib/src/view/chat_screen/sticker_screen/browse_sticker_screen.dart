import 'package:chatmesdk/src/view/widget/appbar.dart';

import '../../../data/sticker_controlller/model/get_all_available_sticker_response_model.dart';
import '../../widget/scaffold_wrapper.dart';
import 'export.dart';

class BrowseStickerScreen extends StatefulWidget {
  const BrowseStickerScreen({Key? key}) : super(key: key);

  @override
  State<BrowseStickerScreen> createState() => _BrowseStickerScreenState();
}

class _BrowseStickerScreenState extends State<BrowseStickerScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StickerController>(
        init: StickerController(),
        builder: (controller) {
          return ScaffoldWrapper(
            color: Colors.white,
            padding: 16,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShareAppbar(title: FontUtil.tr('stickers')),
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
                    child: DebounceBuilder(
                        delay: const Duration(milliseconds: 600),
                        builder: (context, debounce) {
                          return TextField(
                            controller: searchController,
                            autofocus: false,
                            onChanged: (_) => debounce(
                              () => _onSearchSubmit(controller),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              contentPadding: const EdgeInsets.fromLTRB(0, 14, 12, 0),
                              suffixIcon: Offstage(
                                offstage: searchController.text.isEmpty,
                                child: InkWell(
                                  onTap: () {
                                    searchController.clear();
                                    _onClear();
                                  },
                                  child: const Icon(Icons.cancel, color: Colors.grey),
                                ),
                              ),
                              border: InputBorder.none,
                              hintText: 'search_stickers'.tr,
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }),
                  ),
                  searchController.text.isNotEmpty
                      ? controller.searchStickerResult.isEmpty
                          ? Align(
                              child: Text(
                              'no_results_found'.tr,
                              style: AppTextStyle.normalTextRegularGrey,
                            ))
                          : verticalStickerList(
                              controller,
                              controller.searchStickerResult,
                            )
                      : Expanded(
                          child: Column(
                            children: [
                              if (controller.recommendedStickers.isNotEmpty) horizontalStickerList(controller),
                              const SizedBox(height: 12),
                              verticalStickerList(controller, controller.allAvailableStickers)
                            ],
                          ),
                        )
                ],
              ),
            ),
          );
        });
  }

  SizedBox horizontalStickerList(StickerController controller) {
    return SizedBox(
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'recommended_for_you'.tr,
            style: AppTextStyle.normalBold,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: controller.recommendedStickers.length,
              itemBuilder: ((context, recommendIndex) {
                var recommendSticker = controller.recommendedStickers[recommendIndex];
                return InkWell(
                  onTap: () => navigateToStickerDetailScreen(controller.recommendedStickers[recommendIndex].id ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StickerBanner(
                      stickerName: ChatHelper.stickerNameAndDescription(recommendSticker.name),
                      width: 270,
                      thumbnail: recommendSticker.thumbnail,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Expanded verticalStickerList(
    StickerController controller,
    List<AllAvailableStickers> allSticker,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: allSticker.length,
            itemBuilder: ((context, index) {
              var categoryName = allSticker[index];
              var resultSticker = allSticker[index].result;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    ChatHelper.stickerNameAndDescription(categoryName.category).toUpperCase(),
                    style: AppTextStyle.normalBold,
                  ),
                  const SizedBox(height: 8),
                  //*info the sticker items
                  Container(
                    child: Column(
                      children: [
                        ...List.generate(
                          resultSticker?.length ?? 0,
                          (stickerIndex) {
                            var sticker = resultSticker?[stickerIndex];
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => navigateToStickerDetailScreen(
                                    sticker!.id!,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            padding: const EdgeInsets.all(8),
                                            color: const Color(0xffd6d6d6),
                                            child: Image.network(
                                              sticker?.thumbnail ?? '',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ChatHelper.stickerNameAndDescription(sticker?.name),
                                                style: AppTextStyle.normalBold,
                                              ),
                                              Text(ChatHelper.stickerNameAndDescription(sticker?.description),
                                                  style: AppTextStyle.smallTextMediumGrey),
                                            ],
                                          ),
                                        ),
                                        (sticker?.isAdded ?? false)
                                            ? Text('added'.tr, style: AppTextStyle.extraSmallTextBold)
                                            : InkWell(
                                                onTap: () => addStickerToMySticker(
                                                      controller,
                                                      sticker?.id ?? '',
                                                    ),
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: AppColors.primaryColor,
                                                        borderRadius: BorderRadius.circular(4)),
                                                    child: Text(
                                                      'add'.tr,
                                                      style: const TextStyle(
                                                        fontSize: 11.33,
                                                        color: Colors.white,
                                                      ),
                                                    ))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ))
        ],
      ),
    );
  }

  void addStickerToMySticker(StickerController controller, String? groupId) {
    if (groupId == null) return;
    controller.addStickerToMySticker(groupId);
  }

  void navigateToStickerDetailScreen(String groupId) {
    Get.to(() => StickerDetailScreen(groupId: groupId));
  }

  void _onSearchSubmit(StickerController controller) {
    if (searchController.text.isNotEmpty) {
      controller.searchSticker(searchController.text.trim());
    }
  }

  void _onClear() {
    searchController.clear();
    Get.find<StickerController>().searchStickerResult = [];
    setState(() {});
  }
}
