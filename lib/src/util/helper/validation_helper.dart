import 'package:get/get.dart';

import '../constant/app_string.dart';
import 'font_util.dart';

class Validator {
  Validator();

  static String? userName(String value) {
    if (value.isEmpty) {
      return 'please_enter_your_fullname'.tr;
    }
    return null;
  }

  static String? confirmPassword(String newPass, String confirmPass) {
    if (newPass.trim() != confirmPass.trim()) {
      return AppString.password_not_match.tr;
    }
    return null;
  }

  static String? phoneNumber(String value) {
    var regex = RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{2,6}$');
    if (value.trim().isEmpty) {
      return FontUtil.tr(AppString.inputPhonenumber);
    } else if (!regex.hasMatch(value)) {
      return FontUtil.tr(AppString.invalidPhonenumber);
    } else if (value.length > 15) {
      return FontUtil.tr(AppString.invalidPhonenumber);
    } else if (value.contains(' ')) {
      return 'password_not_allow_to_have_space'.tr;
    }
    return null;
  }

  static String mapPhoneNumberWithCountryCode(String code, String phoneNumber) {
    var number = phoneNumber.trim().replaceAll(RegExp(r'^0+(?=.)'), '');
    return code.toUpperCase() + number.trim();
  }

  static String? optCode(String value) {
    if (value.trim().isEmpty) {
      return FontUtil.tr(AppString.inputOtpCode);
    }
    if (value.length != 4) {
      return FontUtil.tr(AppString.invalidOtpCode);
    }
    return null;
  }

  static String? region(bool isSelect) {
    if (!isSelect) {
      return FontUtil.tr(AppString.plsSelecRegion);
    }
    return null;
  }

  static String? password(String value, {bool isSignUp = false}) {
    // from bong hamly
    var regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[A-Za-z\d#$@!%&*?]{8,30}$');
    if (value.isEmpty) {
      return FontUtil.tr(AppString.inputPassword);
    } else if (value.contains(' ') && isSignUp) {
      return 'password_not_allow_to_have_space'.tr;
    } else {
      if (!regex.hasMatch(value)) {
        return AppString.passwordValidation.tr;
      } else {
        return null;
      }
    }
  }

  static String switchAddAccountFrom(String from) {
    switch (from) {
      case 'a_':
        return FontUtil.tr('add_from_accountid');

      case 'p_':
        return FontUtil.tr('add_from_phone_number');

      case 'q_':
        return FontUtil.tr('scanned_qr_code');
      case 'c_':
        return FontUtil.tr('add_from_contact');
      case 'g_':
        return FontUtil.tr('add_from_group');
      default:
        return FontUtil.tr('scanned_qr_code');
    }
  }
}
