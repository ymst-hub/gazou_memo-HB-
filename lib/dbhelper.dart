import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'memo_model.dart';

// Memoテーブルのカラム名を設定
const String columnId = '_id';
const String columnPath = 'path';
const String columnTags = 'tags';
const String columnSentense = 'sentense';

// Memoテーブルのカラム名をListに設定
const List<String> columns = [
  columnId,
  columnPath,
  columnTags,
  columnSentense,
];

// Memoテーブルへのアクセスをまとめたクラス
class DbHelper {
  // DbHelperをinstance化する
  static final DbHelper instance = DbHelper._createInstance();
  static Database? _database;

  DbHelper._createInstance();

  // databaseをオープンしてインスタンス化する
  Future<Database> get database async {
    return _database ??= await _initDB();       // 初回だったら_initDB()=DBオープンする
  }

  // データベースをオープンする
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'Memo.db');    // Memo.dbのパスを取得する

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,      // Memo.dbがなかった時の処理を指定する（DBは勝手に作られる）
    );
  }

  // データベースがなかった時の処理
  Future _onCreate(Database database, int version) async {
    //Memoテーブルをcreateする
    await database.execute('''
      CREATE TABLE Memo(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT,
        tags TEXT,
        sentense TEXT
      )
    ''');
  }

  // Memoテーブルのデータを全件取得する
  Future<List<Memo>> selectAllMemo() async {
    final db = await instance.database;
    final memoData = await db.query('Memo');          // 条件指定しないでMemoテーブルを読み込む

    return memoData.map((json) => Memo.fromJson(json)).toList();    // 読み込んだテーブルデータをListにパースしてreturn
  }

// _idをキーにして1件のデータを読み込む
  Future<Memo> MemoData(int id) async {
    final db = await instance.database;
    var memo = [];
    memo = await db.query(
      'Memo',
      columns: columns,
      where: '_id = ?',                     // 渡されたidをキーにしてMemoテーブルを読み込む
      whereArgs: [id],
    );
    return Memo.fromJson(memo.first);      // 1件だけなので.toListは不要
  }

// データをinsertする
  Future insert(Memo memo) async {
    final db = await database;
    return await db.insert(
        'Memo',
        memo.toJson()                         // memo_model.dartで定義しているtoJson()で渡されたmemoをパースして書き込む
    );
  }

// データをupdateする
  Future update(Memo memo) async {
    final db = await database;
    return await db.update(
      'Memo',
      memo.toJson(),
      where: '_id = ?',                   // idで指定されたデータを更新する
      whereArgs: [memo.id],
    );
  }

// データを削除する
  Future delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Memo',
      where: '_id = ?',                   // idで指定されたデータを削除する
      whereArgs: [id],
    );
  }

  // データをタグから検索する
  Future<List<Memo>> selectTagsMemo(String tags) async {
    final db = await instance.database;
    var memoData = [];
    //検索欄がnullの場合
    if(tags == ''){
      final memoData = await db.query('Memo');          // 条件指定しないでMemoテーブルを読み込む
      return memoData.map((json) => Memo.fromJson(json)).toList();    // 読み込んだテーブルデータをListにパースしてreturn
    }else {
      //nullではない場合
      memoData = await db.query(
        'Memo',
        columns: columns,
        where: 'tags = ?', // 渡されたtagsをキーにしてMemoテーブルを読み込む
        whereArgs: [tags],
      );
      return memoData.map((json) => Memo.fromJson(json))
          .toList(); // 読み込んだテーブルデータをListにパースしてreturn
    }
  }

}