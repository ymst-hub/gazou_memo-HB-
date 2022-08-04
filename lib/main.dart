import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

import 'add_page.dart';
import 'dbhelper.dart';
import 'edit_page.dart';
import 'memo_model.dart';

//高速化を考える

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDRリスト',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'リスト'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Memo> MemoList = [];//DBのMemoデータを取得する
  String _imagePath = '';//保存用のメモを用意
  bool isLoading = false;//ローディングを出す

  //イメージパスの取得メソッド
  _setImagePath() async {
    _imagePath = (await getApplicationDocumentsDirectory()).path;
  }

  //写真の保存メソッド（xfileからパスを作成する）
  Future<String> _savePhoto(XFile _image) async {
    final Uint8List buffer = await _image.readAsBytes();
    final String savePath = '$_imagePath/${_image.name}';
    final File saveFile = File(savePath);
    saveFile.writeAsBytesSync(buffer, flush: true, mode: FileMode.write);
    return saveFile.path;
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      getMemoList();
      _setImagePath();
    });
  }

  // initStateで動かす処理。
  // MEMOテーブルに登録されている全データを取ってくる
  Future getMemoList() async {
    setState(() => isLoading = true);
    MemoList = await DbHelper.instance.selectAllMemo(); //Memoテーブルを全件読み込む
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();//イメージを取得するためのインスタンス
    File? _file;//表示用のfile型


    Future getTagData(String tags) async {//検索バーの処理
      setState(() => isLoading = true);
      MemoList = await DbHelper.instance.selectTagsMemo(tags); //Memoテーブルを全件読み込む
      _setImagePath();//イメージパスをセットする（読み込みによって変動するため）
      setState(() => isLoading = false);
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: TextField(//検索バーの処理
          onChanged: (text) {//1文字入力ごとにそれに当たるものがヒットして、imageListに入れられる
            getTagData(text);
          },
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: '　キーワードを検索',
            contentPadding: EdgeInsets.all(5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      body: isLoading //「読み込み中」だったら「グルグル」が表示される
          ? const Center(
              child: CircularProgressIndicator(), // これが「グルグル」の処理
            )

          : Padding(
            padding: const EdgeInsets.all(4.0),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, //カラム数
                ),
                itemCount: MemoList.length, //要素数
                itemBuilder: (context, index) {
                  //要素を戻り値で返す
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute<Null>(
                                settings: const RouteSettings(),
                                builder: (BuildContext context) {
                                  return EditPage(memo: MemoList[index]);
                                }));
                        setState(() {
                          getMemoList();
                        });
                      },
                      child: Image.file(
                          File('$_imagePath/${MemoList[index].path}'),
                          fit: BoxFit.cover),
                    ),
                  );
                },
                shrinkWrap: true,
              ),
          ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final XFile? _image =
                await _picker.pickImage(source: ImageSource.gallery);
            _file = File(_image!.path);
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                // 遷移先の画面としてリスト追加画面を指定
                return AddPage(image: _image, file: _file);
              }),
            );
            await _savePhoto(_image);
            setState(() {
              getMemoList();
            });
          },
          child: Icon(Icons
              .add)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
