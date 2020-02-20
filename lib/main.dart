import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(
    MaterialApp(
      home: Home(),
      title: "List_agenda",
      debugShowCheckedModeBanner: false,
    ),
  );
}



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String,dynamic> _lastRemoved;
  int _lastRemovePos;

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _toDoController.text;
      _toDoController.text = "";
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
    });
  }
 @override
  void initState() {
      super.initState();
      _readData().then((data){
        _toDoList = json.decode(data);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                      controller: _toDoController,
                      style: TextStyle(
                          color: Colors.cyanAccent[300], fontSize: 14.0),
                      decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(
                          color: Colors.blue, fontSize: 25.0)
                      )
                  ),
                ),
                RaisedButton(
                    color: Colors.blue,
                    child: Icon(Icons.library_add),
                    textColor: Colors.white,
                    onPressed: _addToDo
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _refresh, child:
            ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: builderItem),

            ),
          ),
        ],
      ),
    );


  }


  Widget builderItem(context, index) {
    return Dismissible(
      key: Key(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ), onChanged: (c) {
        setState(() {
          _toDoList[index]["ok"] = c;
          _saveData();
        });
      },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovePos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snackbar = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida"),
            action: SnackBarAction(label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovePos, _lastRemoved);
                  _saveData();
                });
              },),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snackbar);

        });
      },
    );
  }
  Future<Null> _refresh() async{
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _toDoList.sort((a,b){
          if(a["ok"] && !b["ok"])  return 1;
          else if(!a["ok"] && b["ok"]) return -1;
          else return 0;


        });
        _saveData();
      });
      return null;

  }

//Obter algo Sobre o arquivo

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json ");
  }
  //Salvando/Escrevendo arquivo
  Future<File> _saveData() async{
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }
  //Lendo Arquivo
  Future<String> _readData() async {
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch(e){
      return null;
    }
  }



  }

