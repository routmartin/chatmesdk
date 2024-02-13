import 'package:get_storage/get_storage.dart';
import '../../util/constant/app_constant.dart';

class StorageToken {
  static final GetStorage _storage = GetStorage();

  static bool isAccessTokenExist() {
    String? token = _storage.read(AppConstants.token);

    if (token != null) {
      return true;
    }
    return false;
  }

  static String readToken() {
    String? token = _storage.read(AppConstants.token);
    if (token != null) {
      return token;
    }
    return '';
  }

  static String readRefreshToken() {
    String? refreshToken = _storage.read(AppConstants.refreshToken);
    if (refreshToken != null) {
      return refreshToken;
    }
    return '';
  }

  static void deleteToken() {
    _storage.remove(AppConstants.token);
  }

  static Future<void> removeTokenFromStorage() async {
    await _storage.remove(AppConstants.token);
    await _storage.remove(AppConstants.refreshToken);
    await _storage.remove(AppConstants.languageChosen);
    await _storage.remove(AppConstants.dialCode);
    await _storage.remove(AppConstants.warningHide);
    await _storage.remove(AppConstants.warningDelete);
    await _storage.remove(AppConstants.userProfileID);
  }

  static Future<void> saveUserProfileID(String accountId) async {
    await _storage.write(AppConstants.userProfileID, accountId);
  }

  static Future<String> getUserProfileID() async {
    var userId = await _storage.read(AppConstants.userProfileID);
    return userId;
  }

  static Future<void> removeUserProfileID() async {
    await _storage.remove(AppConstants.userProfileID);
  }

  static Future<void> saveLanguage(String lang) async {
    await _storage.write(AppConstants.languageChosen, lang);
  }

  static String readLanguageChosen() {
    String? lang = _storage.read(AppConstants.languageChosen);
    if (lang != null) {
      return lang;
    }
    return 'en';
  }

  static Future<void> saveDialCode(String? dialCode) async {
    await _storage.write(AppConstants.dialCode, dialCode);
  }

  static String readDialCode() {
    String? dialCode = _storage.read(AppConstants.dialCode);
    if (dialCode != null) {
      return dialCode;
    }
    return '0';
  }

  static Future<void> saveWarningHide(bool userConfirm) async {
    await _storage.write(AppConstants.warningHide, userConfirm);
  }

  static bool readWarningHide() {
    bool? userConfirm = _storage.read(AppConstants.warningHide);
    if (userConfirm != null) {
      return userConfirm;
    }
    return false;
  }

  static Future<void> saveWarningDelete(bool userConfirm) async {
    await _storage.write(AppConstants.warningDelete, userConfirm);
  }

  static bool readWarningDelete() {
    bool? userConfirm = _storage.read(AppConstants.warningDelete);
    if (userConfirm != null) {
      return userConfirm;
    }
    return false;
  }

  static Future<void> saveOtpRun(bool userConfirm) async {
    await _storage.write(AppConstants.warningDelete, userConfirm);
  }

  static bool readOtpRun() {
    bool? userConfirm = _storage.read(AppConstants.warningDelete);
    if (userConfirm != null) {
      return userConfirm;
    }
    return false;
  }
}
