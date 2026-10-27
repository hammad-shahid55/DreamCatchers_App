import '../../../core/utils/date_utils.dart';
import '../../profile/models/profile_options.dart';

class SignUpData {
  const SignUpData({
    required this.email,
    required this.password,
    required this.username,
    required this.ethnicity,
    required this.gender,
    required this.relationshipStatus,
    required this.birthday,
    required this.personalityType,
    required this.educationLevel,
  });

  final String email;
  final String password;
  final String username;
  final String ethnicity;
  final String gender;
  final RelationshipStatus relationshipStatus;
  final DateTime birthday;
  final String personalityType;
  final EducationLevel educationLevel;

  Map<String, dynamic> toMetadata() => {
    'username': username.trim(),
    'ethnicity': ethnicity,
    'gender': gender,
    'relationship_status': relationshipStatus.value,
    'birthday': AppDateUtils.isoDate(birthday),
    'personality_type': personalityType,
    'education_level': educationLevel.value,
  };
}
