import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Data {
  String word;
  double value;
  //to store some metadata
  dynamic metaData;
  Data({
    required this.word,
    required this.value,
    this.metaData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'word': word,
      'value': value,
      'metaData': metaData,
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      word: map['word'] as String,
      value: map['value'] as double,
      metaData: map['metaData'] as dynamic,
    );
  }

  String toJson() => json.encode(toMap());

  factory Data.fromJson(String source) => Data.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Data other) {
    if (identical(this, other)) return true;

    return other.word == word && other.value == value && other.metaData == metaData;
  }

  @override
  int get hashCode => word.hashCode ^ value.hashCode ^ metaData.hashCode;

  Data copyWith({
    String? word,
    double? value,
    dynamic metaData,
  }) {
    return Data(
      word: word ?? this.word,
      value: value ?? this.value,
      metaData: metaData ?? this.metaData,
    );
  }

  @override
  String toString() => 'Data(word: $word, value: $value, metaData: $metaData)';
}

class WordCloudData {
  List<Data> data = [];

  WordCloudData({
    required this.data,
  }) {
    data = (data..sort((a, b) => a.value.compareTo(b.value))).reversed.toList();
  }

  void addDataAsMapList(List<Data> newdata) {
    data.addAll(newdata);
    data = (data..sort((a, b) => a.value.compareTo(b.value))).reversed.toList();
  }

  void addData(String word, double value) {
    data.add(Data(word: word, value: value));
    data = (data..sort((a, b) => a.value.compareTo(b.value))).reversed.toList();
  }

  List<Data> getData() {
    return data;
  }
}
