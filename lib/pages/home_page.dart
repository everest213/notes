import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../preferences_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();

  HomePage({Key? key}) : super(key: key) {
    PreferencesHelper.init();
  }
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  final PreferencesHelper _preferencesHelper = PreferencesHelper();

  List<Note>? notes = [];

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NOTES"),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.lightBlueAccent,
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _refreshData,
            child: ListView.builder(
                itemCount: notes!.length,
                itemBuilder: (BuildContext context, int index) =>
                    _customCard(index)),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNewNote,
          tooltip: 'New Note',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _customCard(int index) {
    return Card(
      child: TextButton(
        onPressed: () => _editNote(index),
        child: ListTile(
          title: Text(
            notes![index].text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Future _refreshData() async {
    try {
      await _synchronizeNotes();
      notes = _preferencesHelper.getNotes();

      _refreshController.refreshCompleted();
      if (mounted) setState(() {});
    } catch (e) {
      print(e);
      _refreshController.refreshFailed();
    }
  }

  Future _synchronizeNotes() async {
    var snapshot = await FirebaseFirestore.instance.collection("notes").get();
    List<Note> firestoreNotes =
        snapshot.docs.map((doc) => Note(doc['id'], doc['text'])).toList();

    await _preferencesHelper.synchronizeNotes(firestoreNotes);
  }

  void _createNewNote() {
    Navigator.pushNamed(context, "/note");
  }

  void _editNote(int index) {
    Navigator.pushNamed(context, "/note", arguments: notes![index]);
  }
}
