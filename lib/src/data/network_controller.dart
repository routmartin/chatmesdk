import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectionActivityController extends GetxController {
  bool networkIsConnected = true;
  Connectivity connectivity = Connectivity();

  void checkNetwork() {
    connectivity.onConnectivityChanged.listen((connectivityResult) {
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        networkIsConnected = true;
      } else {
        networkIsConnected = false;
      }
      update();
    });
  }
}
