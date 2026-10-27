import '../../../core/utils/date_utils.dart';
import 'profile_options.dart';

class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    this.ethnicity,
    this.gender,
    this.relationshipStatus,
    this.birthday,
    this.personalityType,
    this.educationLevel,
    this.avatarUrl,
  });

  static const String selectColumns =
      'id, username, ethnicity, gender, relationship_status, birthday, '
      'personality_type, education_level, avatar_url, created_at';

  final String id;
  final String username;
  final String? ethnicity;
  final String? gender;
  final RelationshipStatus? relationshipStatus;
  final DateTime? birthday;
  final String? personalityType;
  final EducationLevel? educationLevel;
  final String? avatarUrl;
  final DateTime createdAt;

  int? get age => birthday == null ? null : AppDateUtils.ageFrom(birthday!);

  Profile withAvatar(String? url) => Profile(
    id: id,
    username: username,
    createdAt: createdAt,
    ethnicity: ethnicity,
    gender: gender,
    relationshipStatus: relationshipStatus,
    birthday: birthday,
    personalityType: personalityType,
    educationLevel: educationLevel,
    avatarUrl: url,
  );

  factory Profile.fromJson(Map<String, dynamic> json) {
    final birthday = json['birthday'] as String?;
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      ethnicity: json['ethnicity'] as String?,
      gender: json['gender'] as String?,
      relationshipStatus: optionFromValue(
        RelationshipStatus.values,
        json['relationship_status'],
      ),
      birthday: birthday == null ? null : DateTime.parse(birthday),
      personalityType: json['personality_type'] as String?,
      educationLevel: optionFromValue(
        EducationLevel.values,
        json['education_level'],
      ),
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
