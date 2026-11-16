import 'package:flutter/material.dart';

// Palet warna aplikasi agar semua bagian halaman selaras.
class AppColors {
  static const Color brown = Color(0xFF563D3A); // teks & AppBar
  static const Color cream = Color(0xFFF0DCC7); // latar belakang halaman
  static const Color peach = Color(0xFFE8A06F); // aksen pengganti krem
  static const Color rose = Color(0xFFC47F78); // aksen tambahan
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506595070";
  final String nama = "Rania Fauziah Nur Wahyudi";
  final String kelas = "PBP D";

  final List<ItemHomepage> items = [
    // Krem diganti peach agar tidak menyatu dengan latar belakang.
    ItemHomepage("Lihat Proyek", Icons.folder, AppColors.peach),
    ItemHomepage("Tambah Proyek", Icons.add_circle, AppColors.rose),
    ItemHomepage("Logout", Icons.logout, AppColors.brown),
  ];

    @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // Latar belakang halaman memakai warna krem.
      backgroundColor: AppColors.cream,
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: AppColors.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.brown,
      ),
      // Body halaman utama dengan padding di sekelilingnya.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
              ],
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                  GridView.count(
                    primary: true,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Kartu memakai warna peach agar selaras dengan palet.
      color: AppColors.peach,
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            // textAlign agar nama panjang tetap rapi di tengah kartu.
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.brown),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

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
        onTap: () {
          // Menampilkan SnackBar dengan pesan interaktif.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  "Kamu telah menekan tombol ${item.name}!",
                  style: const TextStyle(color: AppColors.cream),
                ),
                backgroundColor: AppColors.brown,
              ),
            );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: foregroundColor,
                  size: 30.0,
                ),
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
