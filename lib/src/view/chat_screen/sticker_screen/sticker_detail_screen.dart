import '../../widget/appbar.dart';
import '../../widget/scaffold_wrapper.dart';
import 'export.dart';

class StickerDetailScreen extends StatefulWidget {
  final String groupId;
  const StickerDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<StickerDetailScreen> createState() => _StickerDetailScreenState();
}

class _StickerDetailScreenState extends State<StickerDetailScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<StickerController>().viewEachSticker(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StickerController>(builder: (controller) {
      return ScaffoldWrapper(
          color: Colors.white,
          padding: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ShareAppbar(title: FontUtil.tr('stickers'), onBack: Get.back),
                ),
                const SizedBox(height: 8),
                StickerBanner(
                  stickerName: ChatHelper.stickerNameAndDescription(controller.stickersInDetail?.data?.description),
                  thumbnail: controller.stickersInDetail?.data?.thumbnail,
                  width: double.maxFinite,
                  height: 200,
                ),
                ListTile(
                  title: Text(ChatHelper.stickerNameAndDescription(controller.stickersInDetail?.data?.name)),
                  subtitle: Text(ChatHelper.stickerNameAndDescription(controller.stickersInDetail?.data?.description)),
                  trailing: (controller.stickersInDetail?.data?.isAdded ?? false)
                      ? Text('added'.tr, style: AppTextStyle.extraSmallTextBold)
                      : InkWell(
                          onTap: () {
                            addStickerToMySticker(controller, widget.groupId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'add'.tr,
                              style: const TextStyle(
                                fontSize: 11.33,
                                color: Colors.white,
                              ),
                            ),
                          )),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: controller.stickersInDetail?.data?.stickers?.length ?? 0,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 30,
                      crossAxisCount: 3,
                      crossAxisSpacing: 2.0,
                      childAspectRatio: 4 / 3,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final sticker = controller.stickersInDetail?.data?.stickers?[index];
                      return SizedBox(
                        width: 10,
                        height: 10,
                        child: CachedNetworkImage(
                          imageUrl: sticker?.image ?? '',
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ));
    });
  }

  void addStickerToMySticker(StickerController controller, String? groupId) {
    if (groupId == null) return;
    controller.addStickerToMySticker(groupId);
  }
}
