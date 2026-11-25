import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/screens/skill_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/skill.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class SkillListScreen extends StatefulWidget {
  const SkillListScreen({super.key});

  @override
  State<SkillListScreen> createState() => _SkillListScreenState();
}

class _SkillListScreenState extends State<SkillListScreen> {
  late Future<List<Skill>> _skillsFuture;

  @override
  void initState() {
    super.initState();
    _skillsFuture = context.read<ApiClient>().getSkills();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getSkills();
    setState(() {
      _skillsFuture = future;
    });
    await future;
  }

  Future<void> _addSkill() async {
    if (!await ensureLoggedIn(context) || !mounted) return;

    final Skill? skill = await showDialog<Skill>(
      context: context,
      builder: (_) => const SkillFormDialog(),
    );
    if (skill == null || !mounted) return;

    final String? token = context.read<AuthState>().token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login berakhir. Silakan login lagi.'),
        ),
      );
      return;
    }

    try {
      await context.read<ApiClient>().createSkill(skill, token: token);
      if (!mounted) return;
      setState(() {
        _skillsFuture = context.read<ApiClient>().getSkills();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill berhasil ditambahkan.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menambahkan skill (${error.statusCode}): ${error.message}',
          ),
        ),
      );
    } on http.ClientException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat terhubung ke server: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements: Skills')),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSkill,
        icon: const Icon(Icons.add),
        label: const Text('Add skill'),
      ),
      body: FutureBuilder<List<Skill>>(
        future: _skillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load skills: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final skills = snapshot.data ?? const <Skill>[];

          if (skills.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height - 120,
                  ),
                  child: const Center(child: Text('No skills found.')),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: Text(skill.name),
                    subtitle: Text('${skill.category}\n${skill.description}'),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => SkillDetailScreen(skill: skill),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SkillFormDialog extends StatefulWidget {
  const SkillFormDialog({super.key});

  @override
  State<SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<SkillFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _iconUrlController = TextEditingController();
  String _category = 'programming';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconUrlController.dispose();
    super.dispose();
  }

  String? _validateIconUrl(String? value) {
    final String url = value?.trim() ?? '';
    if (url.isEmpty) return null;

    final Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Icon URL harus berupa alamat http/https yang valid.';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      Skill(
        name: _nameController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        iconUrl: _iconUrlController.text.trim().isEmpty
            ? null
            : _iconUrlController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Skill'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name cannot be empty.'
                    : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: 'programming',
                    child: Text('Programming'),
                  ),
                  DropdownMenuItem(
                    value: 'design',
                    child: Text('Graphic Design'),
                  ),
                  DropdownMenuItem(
                    value: 'soft-skill',
                    child: Text('Soft Skill'),
                  ),
                  DropdownMenuItem(value: 'language', child: Text('Language')),
                  DropdownMenuItem(
                    value: 'drawing',
                    child: Text('Drawing/Painting'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description cannot be empty.'
                    : null,
              ),
              TextFormField(
                controller: _iconUrlController,
                decoration: const InputDecoration(
                  labelText: 'Icon URL (optional)',
                ),
                keyboardType: TextInputType.url,
                validator: _validateIconUrl,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
