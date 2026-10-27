abstract interface class LabeledOption {
  String get value;

  String get label;
}

T? optionFromValue<T extends LabeledOption>(List<T> options, Object? value) {
  for (final option in options) {
    if (option.value == value) return option;
  }
  return null;
}

abstract final class Genders {
  static const List<String> primary = ['Male', 'Female'];

  static const List<String> others = [
    'Agender',
    'Androgynous',
    'Bigender',
    'Cis Man',
    'Cis Woman',
    'Gender Fluid',
    'Gender Nonconforming',
    'Genderqueer',
    'Hijra',
    'Intersex',
    'Neutrois',
    'Non-binary',
    'Pangender',
    'Polygender',
    'Questioning',
    'Third Gender',
    'Transfeminine',
    'Transgender',
    'Trans Man',
    'Transmasculine',
    'Transsexual',
    'Trans Woman',
    'Two-spirit',
    'Others',
  ];
}

enum RelationshipStatus implements LabeledOption {
  single('single', 'Single'),
  inARelationship('in_a_relationship', 'Dating/Romantic Relationship'),
  engaged('engaged', 'Engaged'),
  married('married', 'Married'),
  separated('separated', 'Separated'),
  divorced('divorced', 'Divorced'),
  widowed('widowed', 'Widowed'),
  complicated('its_complicated', 'It\'s complicated'),
  other('other', 'Others');

  const RelationshipStatus(this.value, this.label);

  @override
  final String value;
  @override
  final String label;

  static const List<RelationshipStatus> selectable = [
    single,
    inARelationship,
    married,
    divorced,
    widowed,
    other,
  ];
}

enum EducationLevel implements LabeledOption {
  middleSchool('middle_school', 'Middle School'),
  highSchool('high_school', 'High School'),
  diploma('diploma', 'Diploma / Vocational'),
  associate('associate', 'Associate degree'),
  bachelors('bachelors', 'Bachelor\'s'),
  masters('masters', 'Master\'s/MBA/JD'),
  doctorate('doctorate', 'PhD'),
  other('other', 'Others');

  const EducationLevel(this.value, this.label);

  @override
  final String value;
  @override
  final String label;

  static const List<EducationLevel> selectable = [
    middleSchool,
    highSchool,
    bachelors,
    masters,
    doctorate,
    other,
  ];
}

abstract final class Ethnicities {
  static const List<String> all = [
    'Asian',
    'Arab',
    'Black/African-descent',
    'Hispanic/Latino',
    'Native American',
    'Pacific Islander',
    'South Asian',
    'White/Caucasian',
    'Others',
  ];
}

class PersonalityAxis {
  const PersonalityAxis(this.first, this.second);

  final PersonalityTrait first;
  final PersonalityTrait second;

  List<PersonalityTrait> get traits => [first, second];

  String get label => '${first.letter}/${second.letter}';
}

class PersonalityTrait {
  const PersonalityTrait(this.letter, this.name);

  final String letter;
  final String name;
}

abstract final class PersonalityType {
  static const List<PersonalityAxis> axes = [
    PersonalityAxis(
      PersonalityTrait('I', 'Introvert'),
      PersonalityTrait('E', 'Extravert'),
    ),
    PersonalityAxis(
      PersonalityTrait('S', 'Sensing'),
      PersonalityTrait('N', 'Intuition'),
    ),
    PersonalityAxis(
      PersonalityTrait('F', 'Feeling'),
      PersonalityTrait('T', 'Thinking'),
    ),
    PersonalityAxis(
      PersonalityTrait('P', 'Perceiving'),
      PersonalityTrait('J', 'Judging'),
    ),
  ];

  static bool isValid(String? type) =>
      type != null &&
      type.length == axes.length &&
      List.generate(
        axes.length,
        (i) => i,
      ).every((i) => axes[i].traits.any((t) => t.letter == type[i]));

  static String describe(String type) {
    if (!isValid(type)) return type;
    return [
      for (var i = 0; i < axes.length; i++)
        axes[i].traits.firstWhere((t) => t.letter == type[i]).name,
    ].join(' · ');
  }
}
