import 'dart:convert';

class ProgressEntry {
  final DateTime date;
  final double weight;
  final String? notes;

  ProgressEntry({
    required this.date,
    required this.weight,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
  }

  factory ProgressEntry.fromMap(Map<String, dynamic> map) {
    return ProgressEntry(
      date: DateTime.parse(map['date']),
      weight: map['weight']?.toDouble() ?? 0.0,
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProgressEntry.fromJson(String source) =>
      ProgressEntry.fromMap(json.decode(source));
}
