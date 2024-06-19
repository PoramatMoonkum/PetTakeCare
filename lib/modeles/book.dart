import 'package:pettakecare/modeles/option.dart';
import 'package:pettakecare/modeles/sitter.dart';

class Book {
  int? day;
  bool? onsite;
  String? petName;
  String? petImage;
  Sitter? sitter;
  String? userId;
  String? status;
  Option? options;

  Book({
    this.day,
    this.onsite,
    this.petName,
    this.petImage,
    this.sitter,
    this.userId,
    this.status,
    this.options,
  });

  Book.fromJson(Map<String, dynamic?> json)
      : this(
          day: json['day'] as int?,
          onsite: json['onsite'] as bool?,
          petName: json['pet_name'] as String?,
          petImage: json['pet_image'] as String?,
          // sitter: json['sitter'] != null
          //     ? Sitter.fromJson(json['sitter'] as Map<String, Object?>)
          //     : null,
          userId: json['user_id'] as String?,
          status: json['status'] as String?,
          options: json['options'] != null
              ? Option.fromJson(json['options'] as Map<String, Object?>)
              : null,
        );

  Map<String, Object?> toJson() {
    return {
      'day': day,
      'onsite': onsite,
      'pet_name': petName,
      'pet_image': petImage,
      'sitter': sitter?.toJson(),
      'user_id': userId,
      'status': status,
      'options': options?.toJson(),
    };
  }
}
