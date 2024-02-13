import '../../data/api_helper/storage_token.dart';
import 'validation_helper.dart';

class PhoneNumberHelper {
  PhoneNumberHelper._();

  static String phoneNumberHelper(String number) {
    String result;
    if (number.contains(RegExp(r'[A-Za-z]'))) {
      //check for userId
      return result = number;
    } else {
      //check and convert user phone number
      result = number.replaceAll('-', '').replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '');
      var code = StorageToken.readDialCode();
      var mapPhoneNumber = Validator.mapPhoneNumberWithCountryCode(code, number);
      if (number.startsWith('0')) {
        return mapPhoneNumber.trim();
      } else if (number.startsWith('+')) {
        return result;
      } else if (!number.startsWith('0') && number.length <= 8) {
        return '$code$number';
      } else if (number.length >= 8 && !number.startsWith('+')) {
        return '+$number';
      } else {
        return '+$result';
      }
    }
  }
}
