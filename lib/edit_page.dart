//https://qiita.com/apricotcomic/items/1ef423088c5f67dd0ae4

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gazou_memo/memo_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'dbhelper.dart';

class EditPage extends StatefulWidget {
  final Memo memo;

  const EditPage({Key? key, required this.memo}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late Memo memo = widget.memo;
  bool isLoading = false;

  late String _imagePath = '';

  _setImagePath() async {
    _imagePath = (await getApplicationDocumentsDirectory()).path;
  }

  //イメージパスをセット
  @override
  void initState() {
    super.initState();
    Future(() async {
      setState(() => isLoading = true);
      _setImagePath();
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController tagscontroller =
        TextEditingController(text: memo.tags);
    final TextEditingController sentensescontroller =
        TextEditingController(text: memo.sentense);

    Future updateMemo() async {
      final updatememo = memo.copy(
        // 画面の内容をupdatememoにセット
        id: memo.id,
        path: memo.path,
        tags: tagscontroller.text,
        sentense: sentensescontroller.text,
      );
      await DbHelper.instance.update(updatememo); // updatememoの内容で更新する
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('PDRメモ'),
          actions: [
            IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: () async {
                //更新処理
                await updateMemo();
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                //削除処理
                await DbHelper.instance.delete(memo.id!);
                //ファイルの削除処理
                final String deletePath = '$_imagePath/${memo.path}';
                final File deleteFile = File(deletePath);
                deleteFile.deleteSync();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: isLoading //「読み込み中」だったら「グルグル」が表示される
            ? const Center(
                child: CircularProgressIndicator(), // これが「グルグル」の処理
              )
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(child: _displaySelectionImage()),
                            SizedBox(
                              width: 1.0,
                              height: 30.0,
                            ),
                            TextField(
                              controller: tagscontroller,
                              maxLength: 15,
                              decoration: InputDecoration(
                                hintText: '日付など',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.blueAccent),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 1.0,
                              height: 30.0,
                            ),
                            TextField(
                              controller: sentensescontroller,
                              maxLength: 500,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: '今日の反省',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.blueAccent),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _displaySelectionImage() {
    return Container(
      decoration: BoxDecoration(),
      child: ClipRRect(
          child:
              Image.file(File('$_imagePath/${memo.path}'), fit: BoxFit.cover)),
    );
  }
}
