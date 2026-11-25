import 'package:json_annotation/json_annotation.dart';

part 'skill.g.dart';

/// Skill returned by the Django REST API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Skill {
  const Skill({
    this.id = '',
    required this.name,
    required this.category,
    required this.description,
    this.iconUrl,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);

  @JsonKey(includeToJson: false)
  final String id;
  final String name;
  final String category;
  final String description;
  final String? iconUrl;

  @JsonKey(includeToJson: false)
  final int starCount;

  @JsonKey(includeToJson: false)
  final bool isStarred;

  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
