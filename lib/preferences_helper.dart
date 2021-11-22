import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/note_model.dart';

class PreferencesHelper {
  static late SharedPreferences _sharedPreferences;
  static late Map<String, Note> _notesMap;

  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _notesMap = _extractNotes();
  }

  List<Note>? getNotes() {
    return _notesMap.values.toList();
  }

  Future<bool> addNote(String id, String text) {
    _notesMap[id] = Note(id, text);
    return _sharedPreferences.setString('notes_map', jsonEncode(_notesMap));
  }

  Future<bool> synchronizeNotes(List<Note> remoteNotes) {
    for (var note in remoteNotes) {
      _notesMap[note.id] = note;
    }

    return _sharedPreferences.setString('notes_map', jsonEncode(_notesMap));
  }

  static Map<String, Note> _extractNotes() {
    var storedNotes = _sharedPreferences.getString('notes_map');
    Map json = jsonDecode(storedNotes ?? '{}');

    var notesMap = json.map<String, Note>((key, value) {
      var note = Note.fromJson(value as Map<String, dynamic>);
      return MapEntry<String, Note>(key, note);
    });

    return notesMap;
  }
}
