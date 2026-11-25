import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    // Warna teks/ikon menyesuaikan kecerahan latar kartu:
    // latar gelap -> krem, latar terang -> coklat.
    final Color foregroundColor =
        ThemeData.estimateBrightnessForColor(item.color) == Brightness.dark
        ? AppColors.cream
        : AppColors.brown;

    return Material(
      // Menggunakan warna unik yang dimiliki masing-masing item.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () async {
          // Navigator.push membuat tombol kembali bawaan tetap tersedia.
          switch (item.name) {
            case 'Lihat Skill':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillListScreen(),
                ),
              );
              break;
            case 'Tambah Proyek':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormPage(),
                ),
              );
              break;
            case 'Tambah Pendidikan':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EducationFormPage(),
                ),
              );
              break;
            case 'Login':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              break;
            case 'Logout':
              final messenger = ScaffoldMessenger.of(context);
              try {
                await context.read<AuthState>().logout();
                if (!context.mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Logout berhasil.')),
                );
              } on ApiException catch (error) {
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Sesi lokal dihapus, tetapi logout server gagal '
                      '(${error.statusCode}).',
                    ),
                  ),
                );
              } on http.ClientException catch (error) {
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Sesi lokal dihapus, tetapi server tidak terjangkau: $error',
                    ),
                  ),
                );
              }
              break;
            default:
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Kamu telah menekan tombol ${item.name}!'),
                  ),
                );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: foregroundColor, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
