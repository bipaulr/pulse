import 'package:flutter/foundation.dart';

/// The signed-in user, as far as the UI needs to know.
@immutable
class UserProfile {
  const UserProfile({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';

  /// Fallback for the avatar when there is no photo.
  String get initials =>
      '${_firstLetter(firstName)}${_firstLetter(lastName)}'.toUpperCase();

  static String _firstLetter(String value) =>
      value.isEmpty ? '' : value.substring(0, 1);

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
  );
}
