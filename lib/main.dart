import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/helper_controller.dart';
import 'routes/routes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure async operations can be awaited before app launch
  //await SharedPref.clear();
  // Initialize the LoginController
  Get.put(HelperController());

  // Check for saved auth token in shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? authToken = prefs.getString('auth_token');
  String? restaurant = prefs.getString('restaurant');
  String initialRoute;

  // Decide the initial route
  if (authToken == null) {
    initialRoute = AppRoutes.login; // Redirect to login if no auth token
  } else if (restaurant == null) {
    initialRoute = AppRoutes.config; // Redirect to config if no restaurant data
  } else {
    initialRoute = AppRoutes
        .home; // Redirect to home if both auth token and restaurant are available
  }

  //String initialRoute=AppRoutes.login;
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute, // Set the dynamic initial route
      getPages: AppRoutes.routes,
    );
  }
}
