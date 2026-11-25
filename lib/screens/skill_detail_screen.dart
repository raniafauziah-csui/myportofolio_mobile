import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/skill.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class SkillDetailScreen extends StatelessWidget {
  const SkillDetailScreen({super.key, required this.skill});

  final Skill skill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(skill.name)),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (skill.iconUrl != null && skill.iconUrl!.isNotEmpty)
              Image.network(
                skill.iconUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 160,
                  child: Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              ),
            const SizedBox(height: 16),
            Text(skill.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            _InfoRow(label: 'Category', value: skill.category),
            _InfoRow(label: 'Description', value: skill.description),
            _InfoRow(label: 'Star count', value: '${skill.starCount}'),
            _InfoRow(label: 'Starred', value: skill.isStarred ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
