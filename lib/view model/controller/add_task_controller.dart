import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/data/notifications/notification_service.dart';
import 'package:to_do_app/model/task_model.dart';
import 'package:to_do_app/model/task_stats.dart';
import 'package:to_do_app/model/task_status.dart';
import 'package:to_do_app/utils/utils.dart';
import 'package:to_do_app/view%20model/DbHelper/db_helper.dart';
import 'package:to_do_app/view%20model/controller/home_controller.dart';
import 'package:to_do_app/view/new%20task/components/status_picker.dart';

class AddTaskController extends GetxController {
  final DbHelper database = DbHelper();
  final controller = Get.put(HomeController());
  RxInt selectedImageIndex = 1.obs;
  RxString periority = 'Low'.obs;
  RxBool titleFocus = false.obs;
  RxBool categoryFocus = false.obs;
  RxBool descriptionFocus = false.obs;
  RxBool loading = false.obs;
  Rx<TaskStatus> status = TaskStatus.todo.obs;
  Rx<TextEditingController> title = TextEditingController().obs;
  Rx<TextEditingController> description = TextEditingController().obs;
  Rx<TextEditingController> category = TextEditingController().obs;
  RxString time = ''.obs;
  RxString date = ''.obs;

  insertDataInDatabase() async {
    try {
      loading.value = true;
      final task = TaskModel(
          progress: status.value.progressText,
          status: status.value.storageValue,
          key: DateTime.now().microsecondsSinceEpoch.toString(),
          time: time.value,
          date: date.value,
          periority: periority.value,
          description: description.value.text.toString(),
          category: category.value.text.toString(),
          title: title.value.text.toString(),
          image: Utils.getImage()[selectedImageIndex.value],
          show: 'yes');
      await database.insert(task).then((value) async {
        controller.getTaskData();
        controller.syncPending();
        NotificationService.scheduleTaskReminder(task);
        title.value.clear();
        category.value.clear();
        date.value = '';
        time.value = '';
        status.value = TaskStatus.todo;
        selectedImageIndex.value = 1;
        await Future.delayed(const Duration(milliseconds: 700));
        loading.value = false;

        Get.back();
      }).onError((error, stackTrace) {
        loading.value = false;
      });
    } catch (e) {
      loading.value = false;
      Utils.showSnackBar(
          'task_warning'.tr,
          e.toString(),
          const Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.pinkAccent,
          ));
    }
  }

  showStatusPicker(BuildContext context) {
    if (title.value.text.toString().isEmpty) {
      Utils.showSnackBar(
          'task_warning'.tr,
          'task_add_title'.tr,
          const Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.pinkAccent,
          ));
      return;
    }
    if (category.value.text.toString().isEmpty) {
      Utils.showSnackBar(
          'task_warning'.tr,
          'task_add_category'.tr,
          const Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.pinkAccent,
          ));
      return;
    }
    if (date.value.isEmpty) {
      Utils.showSnackBar(
          'task_warning'.tr,
          'task_add_date'.tr,
          const Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.pinkAccent,
          ));
      return;
    }
    if (int.parse(Utils.getDaysDiffirece(date.value)) < 0) {
      Utils.showSnackBar(
          'task_warning'.tr,
          'task_select_correct_date'.tr,
          const Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.pinkAccent,
          ));
      return;
    }
    StatusPicker(context);
  }

  pickDate(BuildContext context) async {
    // A faixa acompanha o ano corrente: fixá-la em datas absolutas fez o picker
    // parar de abrir quando o calendário passou do lastDate (assert de initialDate).
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 1);
    final DateTime lastDate = DateTime(now.year + 5);
    final DateTime selected = TaskStats.parseDate(date.value) ?? now;
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: selected.isBefore(firstDate)
          ? firstDate
          : selected.isAfter(lastDate)
              ? lastDate
              : selected,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      date.value = Utils.formateDate(pickedDate);
    }
  }

  picTime(BuildContext context) async {
    TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      // Formato de ARMAZENAMENTO da hora — fixo em en_US.
      DateFormat dateFormat = DateFormat('hh:mm a', 'en_US');
      time.value = dateFormat.format(DateTime(
        2323,
        1,
        1,
        pickedTime.hour,
        pickedTime.minute,
      ));
    }
  }

  setTitleFocus() {
    titleFocus.value = true;
    categoryFocus.value = false;
    descriptionFocus.value = false;
  }

  setCategoryFocus() {
    titleFocus.value = false;
    categoryFocus.value = true;
    descriptionFocus.value = false;
  }

  setDescriptionFocus() {
    titleFocus.value = false;
    categoryFocus.value = false;
    descriptionFocus.value = true;
  }

  setPeriority(String value) {
    periority.value = value;
  }

  setStatus(TaskStatus value) {
    status.value = value;
  }

  setImage(int index) {
    selectedImageIndex.value = index;
  }

  onTapOutside() {
    titleFocus.value = false;
    categoryFocus.value = false;
    descriptionFocus.value = false;
  }
}
