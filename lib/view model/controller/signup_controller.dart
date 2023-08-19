import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:to_do_app/utils/utils.dart';
import '../../data/network/firebase/firebase_services.dart';

class SignupController extends GetxController{
  RxBool nameFocus=false.obs;
  RxBool emailFocus=false.obs;
  RxBool passwordFocus=false.obs;
  RxBool correctEmail=false.obs;
  RxBool correctName=false.obs;
  RxBool showPassword=true.obs;
  RxBool loading=false.obs;
  // final FirebaseServices firebase=FirebaseServices();
  final email=TextEditingController().obs;
  final name=TextEditingController().obs;
  final password=TextEditingController().obs;
  void validateEmail(){
    correctEmail.value=Utils.validateEmail(email.value.text.toString());
  }
  void validateName(){
    correctName.value=name.value.text.toString().length>5;
  }
  void setLoading(bool value){
    loading.value=value;
  }
  void createAccount(){
    if(!correctName.value){
      Utils.showSnackBar('Warning', 'Enter Correct Name', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    if(!correctEmail.value){
      Utils.showSnackBar('Warning', 'Enter Correct Email', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    if(password.value.text.toString().length<6){
      Utils.showSnackBar('Warning', 'Password length should greater than 5', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    FirebaseService.createAccount();
  }

  void onFocusEmail(){
    emailFocus.value=true;
    nameFocus.value=false;
    passwordFocus.value=false;
  }
  void onFocusName(){
    emailFocus.value=false;
    nameFocus.value=true;
    passwordFocus.value=false;
  }
  void onFocusPassword(){
    emailFocus.value=false;
    nameFocus.value=false;
    passwordFocus.value=true;
  }
  void onTapOutside(BuildContext context){
    emailFocus.value=false;
    nameFocus.value=false;
    passwordFocus.value=false;
    FocusScope.of(context).unfocus();
  }



}
