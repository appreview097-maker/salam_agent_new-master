import 'package:get/get.dart';

import '../models/user_model.dart';
import '../utilities/shared_preferences.dart';

class HelperController extends GetxController{

   var savedRestaurant, savedRepas, savedMode, savedDisplayImage;
   var user = Rxn<User>();
  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    await loadSavedConfig();
    await loaduserinfo();
  }

  Future<void> loadSavedConfig() async {
    try {
       savedRestaurant = await SharedPref.getConfigValue('selectedRestaurant');
       savedRepas = await SharedPref.getConfigValue('selectedRepas');
       savedMode = await SharedPref.getConfigValue('selectedMode');
       savedDisplayImage = await SharedPref.getDisplay();

    } catch (e) {
      print('helper controller : Error loading config: $e');

    }
  }

  Future<void> loaduserinfo() async{
    user.value = await SharedPref.getUserData();
  }

}