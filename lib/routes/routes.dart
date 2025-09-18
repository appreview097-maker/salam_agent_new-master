import 'package:get/get.dart';
import 'package:salam_agent/views/trans_view.dart';

import '../controllers/home_controller.dart';
import '../views/config_view.dart';
import '../views/forgetpassword_view.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/payment_view.dart';
import '../views/profile_view.dart';
import '../views/scan_view.dart';
import '../views/verification_view.dart';

class AppRoutes {
  // Define all your app routes here
  static const String login = '/login';
  static const String config = '/configuration';
  static const String home = '/home';
  static const String scan='/scan';
  static const String payment='/payment';
  static const String profile='/profile';
  static const String verification='/verification';
  static const String fpso='/fpstepone';
  static const String fpst='/fpsteptwo';
  static const String trans='/transactions';


  static List<GetPage> routes = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: config, page: () => ConfigPage()),
    GetPage(
        name: home,
        page: () => HomePage(),
        binding:BindingsBuilder((){
          Get.lazyPut<HomeController>(() => HomeController());
        })
    ),
    GetPage(name: scan, page: () => QRViewScreen()),
    GetPage(name: payment, page: () => PaymentPage()),
    GetPage(name: profile, page: () => ProfilePage()),
    GetPage(name: verification, page: () => VerificationPage()),
    GetPage(name: fpso, page: () => ForgetPasswordPage()),
    GetPage(name: fpst, page: () => ForgetPasswordPage()),
    GetPage(name: trans, page: () => TransactionsView()),




    // Add more routes as your app grows
  ];
}