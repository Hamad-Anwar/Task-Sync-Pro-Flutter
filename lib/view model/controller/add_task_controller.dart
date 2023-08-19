import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:to_do_app/view%20model/DbHelper/db_helper.dart';
import 'package:to_do_app/view%20model/controller/home_controller.dart';
import 'package:to_do_app/view/new%20task/components/progress_picker.dart';

class AddTaskController extends GetxController{
  final DbHelper database=DbHelper();
  final controller=Get.put(HomeController());
  RxInt selectedImageIndex=1.obs;
  RxBool lowPeriority=true.obs;
  RxBool titleFocus=false.obs;
  RxBool categoryFocus=false.obs;
  RxBool descriptionFocus=false.obs;
  RxBool loading=false.obs;
  RxDouble progress=0.0.obs;
  Rx<TextEditingController> title=TextEditingController().obs;
  Rx<TextEditingController> description=TextEditingController().obs;
  Rx<TextEditingController> category=TextEditingController().obs;
  RxString time=''.obs;
  RxString date=''.obs;



  insertDataInDatabase() async {
    try{
      loading.value=true;
     await database.insert(TaskModel(
       progress: progress.value.toInt().toString(),
          status: 'unComplete',
          key: DateTime.now().microsecondsSinceEpoch.toString(),
          time: time.value,
          date: date.value,
          periority: lowPeriority.value ? 'High' : 'Low',
          description: description.value.text.toString(),
          category: category.value.text.toString(),
          title: title.value.text.toString(),
          image: Utils.getImage()[selectedImageIndex.value],
          show: 'yes'
     )).then((value) async {
       controller.getTaskData();
       title.value.clear();
       category.value.clear();
       date.value='';
       time.value='';
       progress.value=0.0;
       selectedImageIndex.value=1;
            await Future.delayed(const Duration(milliseconds: 700));
       loading.value=false;

            Get.back();
     }).onError((error, stackTrace){
       loading.value=false;
     });

    }catch(e){
       loading.value=false;
      Utils.showSnackBar('Warning', e.toString(), const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pinkAccent,));
    }
  }
  showProgressPicker(BuildContext context){
    if(title.value.text.toString().isEmpty){
      Utils.showSnackBar('Warning', 'Add title of your task', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pinkAccent,));
      return;
    }
    if(category.value.text.toString().isEmpty){
      Utils.showSnackBar('Warning', 'Add category of your task', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pinkAccent,));
      return;
    }
    if(date.value.isEmpty){
      Utils.showSnackBar('Warning', 'Add date for your task', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pinkAccent,));
      return;
    }
    if(int.parse(Utils.getDaysDiffirece(date.value))<0){
      Utils.showSnackBar('Warning', 'Please select correct date', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pinkAccent,));
      return;
    }
    ProgressPicker(context);
  }
  pickDate(BuildContext context)async{
    var pickedDate=await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if(pickedDate!=null){
      date.value=Utils.formateDate(pickedDate);
    }
  }
  picTime(BuildContext context)async{
    TimeOfDay? pickedTime=await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if(pickedTime!=null){
      DateFormat dateFormat = DateFormat('hh:mm a');
      time.value=dateFormat.format(DateTime(2323,1,1,pickedTime.hour,pickedTime.minute,));
    }
  }
  setTitleFocus(){
    titleFocus.value=true;
    categoryFocus.value=false;
    descriptionFocus.value=false;
  }
  setCategoryFocus(){
    titleFocus.value=false;
    categoryFocus.value=true;
    descriptionFocus.value=false;
  }
  setDescriptionFocus(){
    titleFocus.value=false;
    categoryFocus.value=false;
    descriptionFocus.value=true;
  }
  setPeriority(bool value){
    lowPeriority.value=value;
  }
  setImage(int index){
    selectedImageIndex.value=index;
  }
  onTapOutside(){
    titleFocus.value=false;
    categoryFocus.value=false;
    descriptionFocus.value=false;
  }


}