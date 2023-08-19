import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:to_do_app/Data/network/firebase/firebase_services.dart';
import 'package:to_do_app/Data/shared%20pref/shared_pref.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:to_do_app/view%20model/DbHelper/db_helper.dart';
import '../../model/task_model.dart';

class HomeController extends GetxController {
  RxMap userData = {}.obs;
  RxString name = ''.obs;
  RxBool focus = false.obs;
  RxBool hasText = false.obs;
  RxInt taskCount = 0.obs;
  RxBool hasData = false.obs;
  final DbHelper db = DbHelper();
  RxList list = [].obs;
  Connectivity? connectivity;
  final searchController = TextEditingController().obs;
  HomeController() {
    // if name not loaded
    if (userData['NAME'] == null) {
      getUserData();
    }
    // check for set listeners only for one time
    if (connectivity == null) {
      String str = FirebaseService.auth.currentUser!.email.toString();
      String node = str.substring(0, str.indexOf('@'));
      // listener for changing live database
      FirebaseDatabase.instance
          .ref('Tasks')
          .child(node)
          .onValue
          .listen((event) async {
        int count = await FirebaseService.childCount();
        // check if live database has more child than local

        getTaskData();
        for (var element in event.snapshot.children) {
          if (!await db.isRowExists(
              element.child('key').value.toString(), 'Tasks')) {
            db
                .insert(
              TaskModel(
                  key: element.child('key').value.toString(),
                  time: element.child('time').value.toString(),
                  progress: element.child('progress').value.toString(),
                  status: element.child('status').value.toString(),
                  date: element.child('date').value.toString(),
                  periority: element.child('periority').value.toString(),
                  description: element.child('description').value.toString(),
                  category: element.child('category').value.toString(),
                  title: element.child('title').value.toString(),
                  image: element.child('image').value.toString(),
                  show: element.child('show').value.toString()),
            )
                .then((value) {
              getTaskData();
            });
          }
        }
      });

      FirebaseDatabase.instance
          .ref('Tasks')
          .child(node)
          .onChildChanged
          .listen((event) async {
        int count = await FirebaseService.childCount();

        // check if live database has more child than local
        getTaskData();
        for (var element in event.snapshot.children) {
          db
              .update(TaskModel(
              progress: element.child('progress').value.toString(),
              status: element.child('status').value.toString(),
                  key: element.child('key').value.toString(),
                  time: element.child('time').value.toString(),
                  date: element.child('date').value.toString(),
                  periority: element.child('periority').value.toString(),
                  description: element.child('description').value.toString(),
                  category: element.child('category').value.toString(),
                  title: element.child('title').value.toString(),
                  image: element.child('image').value.toString(),
                  show: element.child('show').value.toString()))
              .then((value) {
            getTaskData();
          });
        }
      });
      connectivity = Connectivity();
      // listener for internet state
      connectivity!.onConnectivityChanged.listen((event) async {
        if (event == ConnectivityResult.mobile ||
            event == ConnectivityResult.wifi) {
          var list = await db.getPendingUploads();
          for (int i = 0; i < list.length; i++) {
            db.insert(list[i]);
            db.delete(list[i].key!, 'PendingUploads');
          }
          list.clear();
          list = await db.getPendingDeletes();
          for (int i = 0; i < list.length; i++) {
            FirebaseService.update(list[i].key!, 'show', 'no');
            db.delete(list[i].key!, 'PendingDeletes');
          }
          getTaskData();
        }
      });
    }
    getTaskData();
  }
  checkData() {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].show == 'yes') {
        count++;
      }
    }
    if (count > 0) {
      hasData.value = true;
      taskCount.value = count;
    } else {
      hasData.value = false;
      taskCount.value = 0;
    }
  }
  popupMenuSelected(int value, int index, BuildContext context) async {
    if (value == 2) {
      Utils.showWarningDailog(context, () => removeFromList(index));
    }
  }
  getTaskData() async {
    list.value = await db.getData();
    var tempList = await db.getPendingUploads();
    for (int i = 0; i < tempList.length; i++) {
      list.add(tempList[i]);
    }
    checkData();
  }
  Future<List<TaskModel>> getFututeData() {
    return db.getData();
  }
  onClear(BuildContext context) {
    searchController.value.text = '';
    hasText.value = false;
    onTapOutside(context);
  }
  onTapOutside(BuildContext context) {
    focus.value = false;
    FocusScope.of(context).unfocus();
  }
  checkText() {
    hasText.value = searchController.value.text.toString().isNotEmpty;
  }
  onTapField() {
    focus.value = true;
  }
  getUserData() async {
    userData.value = await UserPref.getUser();
    getName();
  }
  getName() {
    name.value = userData['NAME']
        .toString()
        .substring(0, userData['NAME'].toString().indexOf(' '));
  }
  removeFromList(int index) {
    db
        .removeFromList(TaskModel(
            key: list[index].key,
            status: list[index].status,
            progress: list[index].progress,
            time: list[index].time,
            date: list[index].date,
            periority: list[index].periority,
            description: list[index].description,
            category: list[index].category,
            title: list[index].title,
            image: list[index].image,
            show: 'no'))
        .then((value) {
      getTaskData();
    });
  }
}
