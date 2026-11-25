import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/skill.dart';

void main() {
  test('Skill maps API snake_case fields and nullable icon URL', () {
    final Skill skill = Skill.fromJson({
      'id': '5b4722b3-2b4e-4e8c-9aef-b0ff4d3e3210',
      'name': 'Flutter',
      'category': 'programming',
      'description': 'Mobile app development',
      'icon_url': null,
      'star_count': 3,
      'is_starred': false,
    });

    expect(skill.name, 'Flutter');
    expect(skill.category, 'programming');
    expect(skill.iconUrl, isNull);
    expect(skill.starCount, 3);
    expect(skill.isStarred, isFalse);
    expect(skill.toJson(), {
      'name': 'Flutter',
      'category': 'programming',
      'description': 'Mobile app development',
      'icon_url': null,
    });
  });
}
