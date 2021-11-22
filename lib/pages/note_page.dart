import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note_model.dart';
import 'package:uuid/uuid.dart';
import '../preferences_helper.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NotePageState();
}

class NotePageState extends State<NotePage> {
  final myController = TextEditingController();
  Note? note;

  NotePageState();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var argument = ModalRoute.of(context)!.settings.arguments;
    if (argument is Note?) {
      note = ModalRoute.of(context)!.settings.arguments as Note?;
    }

    myController.text = note?.text ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(note == null ? "NEW NOTE" : "EDIT NOTE")),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_inputField(), const SizedBox(height: 16), _saveButton()],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _inputField() {
    return Expanded(
      child: TextFormField(
        controller: myController,
        maxLines: 99999,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          label: Text("Enter your thoughts"),
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _saveButton() {
    return TextButton(
      onPressed: _saveNote,
      child: const Text(
        "Save",
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
      ),
    );
  }

  Future _saveNote() async {
    var id = note?.id ?? const Uuid().v1();
    var text = myController.text;

    try {
      //awaiting response never ends
      FirebaseFirestore.instance
          .collection("notes")
          .add({"id": id, "text": text});

      Navigator.pop(context);
      return;
    } catch (e) {
      print(e);
    }

    try {
      await PreferencesHelper().addNote(id, text);

      Navigator.pop(context);
      return;
    } catch (e) {
      print(e);
    }
  }
}
