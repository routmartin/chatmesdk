import 'environment.dart';

class SocketPath {
  //** */ based path

  //** */ production
  static const String basedUrlprod = 'wss://core.chat-me.chat';
  static const String httpBaseUrlprod = 'https://core.chat-me.chat';

  //** */ stagging
  static const String baseUrlenv = 'ws://core.chatme.com';
  static const String httpBaseUrldev = 'http://core.chatme.com';
//** */ local
  // static const String baseUrl_dev = 'ws://192.168.160.122:3000';
  // static const String httpBaseUrl_dev = 'http://192.168.160.155:3002';

  ///
  /// *** Please copy ***:
  /// environment.dart.example -> environment.dart
  static bool devMode = Environment.isDevMode;

  static String get baseUrl => devMode ? baseUrlenv : basedUrlprod;

  static String get httpBaseUrl => devMode ? httpBaseUrldev : httpBaseUrlprod;

  //namespace
  static const String auth = '/auth';
  static const String profile = '/profile';
  static const String country = '/country';
  static const String device = '/device';
  static const String termOfService = '/legal-document';
  static const String feedback = '/feedback';
  static const String contact = '/contact';
  static const String addFriend = '/friend-request';
  static const String report = '/report';
  static const String listMessage = '/listMessage';
  static const String room = '/room';
  static const String message = '/message';
  static const String group = '/group';

  //event
  //* Add Friend and confirm friend
  static const String addNewFriendBySyncContact = 'friend:addNewFriendRequest';
  static const String addNewFriendBySearch = 'friend:searchFriend';
  static const String confirmFriendRequest = 'friend:confirmFriendRequest';
  static const String friendRequestList = 'friend:get';
  static const String friendRequestCount = 'friend:countUnseen';
  static const String viewFriendRequest = 'friend:viewFriendRequest';
  static const String countUnseen = 'friend:countUnseen';

  //* auth event
  static const String signUp = 'auth:signup';
  static const String signOut = 'auth:logout';
  static const String signInPassword = 'auth:loginWithPassword';
  static const String requestSignInOTPCode = 'auth:loginWithOtp';
  static const String requestSignInOTPCodeVerify = 'auth:verifyOtp';
  static const String requestOTP = 'auth:requestOtp';
  static const String verifyOTP = 'auth:verifyOtp';
  static const String verifyQR = 'auth:verifyQr';
  static const String confrimQR = 'auth:confirmQr';
  static const String refreshToken = 'auth:refreshToken';
  static const String cancelDesktopLogin = 'auth:cancelQr';
  static const String pushVersionUpdate = 'auth:version';
  static const String getDownloadAppUrl = 'auth:latestVersion';
  static const String registerReferralCode = 'auth:agent';
  static const String versionUpdate = 'version:release';

  //* profile event
  static const String updateProfile = 'profile:updateProfile';
  static const String changeProfileAccountId = 'profile:changeProfileAccountId';
  static const String resetPasswordWithOldPassword = 'auth:resetPasswordWithOldPassword';
  static const String resetPasswordWithOtp = 'auth:resetPasswordWithOtp';
  static const String getFriendPermission = 'profile:getFriendPermission';
  static const String getProfile = 'profile:getProfile';
  static const String changePhoneNumber = 'profile:changePhoneNumber';
  static const String updateNotification = 'profile:updateNotification';
  static const String getUserProfile = 'profile:getUserProfile';

  //* device event
  static const String getDevices = 'device:getLoggedInLoggedOutDevice';
  static const String deleteDevices = 'device:delete';
  static const String updateDevices = 'device:put';
  static const String logOutDevices = 'device:logout';

  //* other event
  static const String createFeedback = 'feedback:createFeedback';
  static const String getCountryCode = 'country:getListCountry';
  static const String getTermOfServiceDoc = 'legal-document:get';

//* attachment
  static const String uploadFile = '/attachment/upload';

//* contact
  static const String syncContact = 'contact:syncContact';
  static const String getContactList = 'contact:getContactList';
  static const String editContact = 'contact:edit';
  static const String deleteContact = 'contact:delete';
  static const String blockContact = 'contact:blockContact';
  static const String unblockContact = 'contact:unblockContact';
  static const String blockList = 'contact:blockList';

  //*report
  static const String reportList = 'report:getCategories';
  static const String createReport = 'report:createReport';

  //*rooom
  static const String searchContactAndGroupChat = 'room:searchContactAndGroupChat';
  static const String searchChatHistory = 'room:searchChatHistory';
  static const String recentSearchHistory = 'room:getSearchHistory';
  static const String saveSearchHistory = 'room:createSearchHistory';
  static const String clearRecentSearchHistory = 'room:clearSearchHistory';
  static const String getChatRooms = 'room:getRooms';
  static const String listUserSeen = 'message:listUserSeen';
  static const String markAsRead = 'room:markAsRead';
  static const String markAsUnread = 'room:markAsUnread';
  static const String muteRoom = 'room:updateMuted';
  static const String roomMute = 'room:muted';

  //*group
  static const String createGroup = 'group:create';
  static const String updateGroupName = 'group:updateGroupName';
  static const String updateGroupDecription = 'group:updateGroupDescription';
  static const String updateGroupAvatar = 'group:updateGroupAvatar';
  static const String getGroupMember = 'group:getMember';
  static const String addGroupMember = 'group:addMember';
  static const String leaveGroup = 'group:leaveGroup';
  static const String transferOwnerShip = 'group:transferOwnerShip';
  static const String disbandGroup = 'group:disbandGroup';
  static const String removeMemberFromTheGroup = 'group:removeMemberFromTheGroup';
  static const String assignMemberToBeAdmin = 'group:assignMemberToBeAdmin';
  static const String removeAdminFromAdminGroup = 'group:removeAdminFromAdminGroup';
  static const String updateGroupPrivacy = 'group:updateGroupPrivacy';
  static const String listJoinRequest = 'group:listJoinRequest';
  static const String confirmJoinRequest = 'group:confirmJoinRequest';
  static const String updateMyNickName = 'group:updateMyNickName';
  static const String joinViaQRCode = 'group:joinViaQRCode';
  static const String groupInfo = 'group:getGroupInfo';
  static const String getTotalMember = 'group:getTotalMember';

  //*message
  static const String sendMessage = 'message:sendMessage';
  static const String receiveMessage = 'message:receiveMessage';
  static const String getMessages = 'message:getMessages';
  static const String deleteOwnMessage = 'message:deleteOwnMessage';
  static const String unsendMessage = 'message:unsendMessage';
  static const String onTyping = 'message:onTyping';
  static const String onUploading = 'message:onUploading';
  static const String pinnedMessages = 'message:pin';
  static const String unpinnedMessages = 'message:unpin';
  static const String seenMessage = 'message:seenMessage';
  static const String userOnline = 'user:online';
  static const String hideChatRoom = 'room:hideChat';
  static const String deleteChat = 'message:clearChatMessages';
  static const String saveDraft = 'room:saveDraft';
  static const String deleteDraft = 'room:deleteDraft';
  static const String totalUnReadCount = 'message:countUnread';
  static const String totalBadge = 'message:totalBadge';
  static const String trackWhichRoomUserOn = 'message:trackWhichRoomUserOn';
  static const String onRecording = 'message:onRecording';

  //*sticker
  static const String mySticker = 'message:mySticker';
  static const String listAllSticker = 'message:listAllSticker';
  static const String getRecommendSticker = 'message:recommededSticker';
  static const String addSticker = 'message:addSticker';
  static const String viewEachSticker = 'message:viewSticker';
  static const String removeSticker = 'message:removeSticker';
  static const String recentUsedSticker = 'message:recentUsed';

  //*call
  static const String audioCall = 'message:requestVoiceCall';
  static const String voiceCall = 'message:voiceCall';
  static const String joinCall = 'message:joinVoiceCall';
  static const String endCall = 'message:endVoiceCall';
  static const String declineVoiceCall = 'message:declineVoiceCall';
  static const String muteCall = 'message:muteCall';
  static const String unMuteCall = 'message:unmuteCall';
  static const String removeUserFromCall = 'message:removeUserFromCall';

  //*call member in group
  static const String getGroupMemberCall = 'group:getCallingMember';
}
