import 'package:intl/intl.dart';

import 'dbhelper.dart';

// catsテーブルの定義
class Memo {
  int? id;
  String path;
  String tags;
  String sentense;

  Memo({
    this.id,
    required this.path,
    required this.tags,
    required this.sentense,
  });

// 更新時のデータを入力項目からコピーする処理
  Memo copy({
    int? id,
    String? path,
    String? tags,
    String? sentense,
  }) =>
      Memo(
        id: id ?? this.id,
        path: path ?? this.path,
        tags: tags ?? this.tags,
        sentense: sentense ?? this.sentense,
      );

  static Memo fromJson(Map<String, Object?> json) => Memo(
    id: json[columnId] as int,
    path: json[columnPath] as String,
    tags: json[columnTags] as String,
    sentense: json[columnSentense] as String,
  );

  Map<String, Object> toJson() => {
    columnPath: path,
    columnTags: tags,
    columnSentense: sentense,
  };
}