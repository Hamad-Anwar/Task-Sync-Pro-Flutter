import 'dart:core';

class TaskModel {
  String? key;
  String? title;
  String? category;
  String? description;
  String? image;
  String? periority;
  String? time;
  String? date;
  String? show;
  String? progress;
  String? status;

  /// Instante (ms desde a época, como texto) da última alteração feita no app.
  /// Decide conflitos entre aparelhos: a versão mais nova vence.
  String? updatedAt;

  TaskModel(
      {required this.key,
      required this.time,
      required this.date,
      required this.periority,
      required this.description,
      required this.category,
      required this.title,
      required this.image,
      required this.show,
      required this.progress,
      required this.status,
      this.updatedAt});

  TaskModel.fromMap(Map<String, dynamic> res) {
    key = res['key'];
    title = res['title'];
    category = res['category'];
    description = res['description'];
    image = res['image'];
    periority = res['periority'];
    show = res['show'];
    time = res['time'];
    date = res['date'];
    progress = res['progress'];
    status = res['status'];
    updatedAt = res['updatedAt']?.toString();
  }

  /// [updatedAt] como número; tasks antigas (sem o campo) valem 0.
  int get updatedAtMillis => int.tryParse(updatedAt ?? '') ?? 0;

  /// Lê o `updatedAt` de um valor cru do Firebase (Map) ou 0 se não houver.
  static int updatedAtOf(Object? remoteValue) {
    if (remoteValue is Map) {
      return int.tryParse(remoteValue['updatedAt']?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  Map<String, Object?> toMap() {
    return {
      'key': key,
      'title': title,
      'category': category,
      'description': description,
      'image': image,
      'periority': periority,
      'time': time,
      'date': date,
      'show': show,
      'status': status,
      'progress': progress,
      'updatedAt': updatedAt,
    };
  }
}
