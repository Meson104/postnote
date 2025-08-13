import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/utils.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotesModel {
  final String id;
  final String uid;
  final String title;
  final String content;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;
  NotesModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  NotesModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? content,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotesModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'title': title,
      'content': content,
      'hexColor': rgbToHex(color),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory NotesModel.fromMap(Map<String, dynamic> map) {
    return NotesModel(
      id: map['id'] ?? "",
      uid: map['uid'] ?? "",
      title: map['title'] ?? "",
      content: map['content'] ?? "",
      color: hexToRgb(map['hexColor']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotesModel.fromJson(String source) =>
      NotesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotesModel(id: $id, uid: $uid, title: $title, content: $content, color : $color, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant NotesModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.title == title &&
        other.content == content &&
        other.color == color &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        title.hashCode ^
        content.hashCode ^
        color.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
