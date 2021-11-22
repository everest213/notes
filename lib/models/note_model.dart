class Note {
  Note(this.id, this.text);
  String id;
  String text;

  Map<String, dynamic> toJson() => {"id": id, "text": text};

  static Note fromJson(Map<String, dynamic> json) {
    String id = json["id"];
    String text = json["text"];

    return Note(id, text);
  }
}
