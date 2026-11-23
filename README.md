# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

**AI Disclosure**
Dalam proses pengerjaan tugas ini, saya menggunakan bantuan Artificial Intelligence (AI), yaitu ChatGPT, sebagai alat bantu untuk memperbaiki error pada pekerjaan saya dan melengkapi jawaban reflektif sekaligus membantu agar saya memahami pekerjaan saya secara lebih dalam. AI digunakan untuk membantu menjelaskan konsep, memberikan contoh, serta menyederhanakan bahasa agar lebih mudah dipahami. Seluruh jawaban kemudian saya baca, pelajari, dan sesuaikan kembali dengan pemahaman saya sebelum digunakan dalam tugas ini.

### Tugas 8
1. Navigator.push() untuk membuka halaman baru di atas halaman sebelumnya tanpa menghapus halaman lama, Navigator.pushReplacement() untuk membuka halaman baru sekaligus menggantikan halaman sebelumnya, dan Navigator.pop() untuk menutup halaman yang sedang dibuka dan kembali ke halaman sebelumnya. Metode yang digunakan untuk membuka formulir dari kartu aksi adalah Navigator.push(), karena pengguna dapat membuka formulir dan kembali ke halaman utama tanpa kehilangan halaman sebelumnya. Opsi Home pada Drawer menggunakan navigasi menuju halaman utama, biasanya dengan Navigator.pop() untuk menutup Drawer dan Navigator.pushReplacement() untuk kembali ke halaman Home.

2. Scaffold menjadi kerangka utama halaman pada flutter, AppBar menampilkan bagian atas halaman seperti judul dan tombol navigasi, dan Drawer menyediakan menu navigasi ke halaman lain. Ketiganya membantu menjaga tampilan dan navigasi aplikasi konsisten. Contohnya, warna utama untuk portfolio dapat digunakan pada AppBar home dan formulir lewat ThemeData agar seragam. 

3. Tata letak formulir dipilih agar setiap kolom input tersusun rapi, mudah dibaca, dan mudah digunakan oleh pengguna. SizedBox memberikan jarak antarwidget agar formulir tidak terlalu rapat, Padding memberikan ruang di sekitar widget agar tampilan lebih nyaman, dan SingleChildScrollView memungkinkan halaman digulir ketika formulir lebih panjang daripada ukuran layar, terutama saat keyboard muncul. Dengan demikian, seluruh bagian formulir tetap dapat diakses meskipun ruang layar terbatas.

4. GlobalKey<FormState> digunakan untuk mengidentifikasi dan mengakses kondisi formulir, validator berfungsi memeriksa apakah nilai yang dimasukkan pengguna sudah sesuai aturan, dan validate() menjalankan seluruh validator ketika tombol Simpan ditekan dan menentukan apakah formulir valid. Contoh nilai yang ditolak adalah kolom URL berisi abc123, karena tidak memiliki format alamat URL yang benar. Namun, memilih jenis input atau papan ketik, seperti TextInputType.URL, saja belum cukup karena hanya membantu pengguna memasukkan data dengan lebih mudah, bukan memastikan data yang dimasukkan benar.