import 'export.dart';

class StickerChatTextfieldFooterScreen extends StatefulWidget {
  final Function(String id) onSentSticker;
  const StickerChatTextfieldFooterScreen({
    Key? key,
    required this.onSentSticker,
  }) : super(key: key);

  @override
  State<StickerChatTextfieldFooterScreen> createState() => _StickerChatTextfieldFooterScreenState();
}

class _StickerChatTextfieldFooterScreenState extends State<StickerChatTextfieldFooterScreen>
    with SingleTickerProviderStateMixin {
  int initIndex = 0;
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * .4,
      child: GetBuilder<StickerController>(builder: (_controller) {
        return _controller.isLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _controller.tabController,
                    onTap: onTapChange,
                    isScrollable: true,
                    indicatorColor: Colors.transparent,
                    labelPadding: EdgeInsets.zero,
                    tabs: List.generate(
                      _controller.tabBarName.length,
                      (index) => Tab(
                        height: 60,
                        child: Container(
                          width: 50,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: index == selectedIndex ? Color(0xffD9D9D9).withOpacity(.5) : Colors.transparent,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: _controller.tabBarName[index].thumbnail ?? '',
                            errorWidget: (context, url, error) => Image.asset(
                              _controller.tabBarName[index].thumbnail!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: [
                    stickerPopUpScreen(_controller, selectedIndex),
                  ][initIndex])
                ],
              );
      }),
    );
  }

  Widget stickerPopUpScreen(StickerController controller, int index) {
    var recentIndex = 1;
    var lastIndex = controller.tabBarName.length - 1;
    var firstIndex = 0;
    var _stickerList;

    if (index == recentIndex) {
      _stickerList = controller.recentUsedStickers;
    } else if (index == firstIndex || index == lastIndex) {
      return SizedBox.shrink();
    } else {
      _stickerList = controller.mySticker?[index - 2].stickers;
    }
    var len = _stickerList?.length ?? 0;
    return len == 0 || len == null
        ? Center(
            child: Text(
              'you_haven’t_sent_any_stickers_yet'.tr,
              style: AppTextStyle.smallTextMediumGrey,
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(8),
            itemCount: len,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 30,
              crossAxisCount: 4,
              crossAxisSpacing: 2.0,
              childAspectRatio: 5 / 3,
            ),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  _onSentSticker(_stickerList[index].id);
                },
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CachedNetworkImage(
                    imageUrl: _stickerList?[index].image ?? '',
                    placeholder: (context, url) => Center(
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive()),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              );
            },
          );
  }

  void onTapChange(index) {
    StickerController _controller = Get.find();
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      _navigateToEditMyStickerScreen();
    }
    if (selectedIndex == 1) {
      _getRecentlyUsedSticker();
    }
    if (selectedIndex == _controller.tabBarName.length - 1) {
      _navigateToStickerScreen();
    }
  }

  void _navigateToStickerScreen() {
    Get.find<StickerController>().getAllAvailableSticker();
    Get.find<StickerController>().getRecommendSticker();
    Get.to(() => BrowseStickerScreen())!.then((_) {
      selectedIndex = 1;
      setState(() {});
    });
  }

  void _navigateToEditMyStickerScreen() {
    Get.to(() => MyStickerScreen())!.then((_) {
      selectedIndex = 1;
      setState(() {});
    });
  }

  void _onSentSticker(String id) {
    widget.onSentSticker(id);
  }

  void _getRecentlyUsedSticker() {
    Get.find<StickerController>().getRecentUsedStickers();
  }
}
