import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

Finder field(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
}

Future<void> _tapSave(WidgetTester tester) async {
  // Gulir ke bawah supaya tombol Simpan selalu dapat dijangkau,
  // termasuk saat pesan error menambah tinggi konten formulir.
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0, -800),
  );
  await tester.pumpAndSettle();
  final Finder button = find.byType(ElevatedButton);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _pickDay(WidgetTester tester, String label, String day) async {
  await tester.tap(field(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(day).first);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Halaman utama menampilkan profil dan kartu aksi baru', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506595070'), findsOneWidget);
    expect(find.text('Rania Fauziah Nur Wahyudi'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Tambah Pendidikan'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Kartu aksi membuka form dengan Navigator.push dan bisa kembali', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Pendidikan'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);

    // Navigator.push membuat rute bisa di-pop (tombol kembali perangkat).
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    expect(navigator.canPop(), isTrue);
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Drawer membuka Add Education dan Home kembali ke menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Opsi lama tetap ada.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.text('Add Education'), findsOneWidget);

    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);

    // Drawer yang sama juga dipakai di halaman formulir baru.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Validasi menolak kosong, spasi, panjang, dan URL invalid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await _tapSave(tester);
    await tester.pump();

    expect(find.text('Nama institusi tidak boleh kosong.'), findsOneWidget);
    expect(find.text('Jurusan tidak boleh kosong.'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib dipilih.'), findsOneWidget);
    expect(find.text('Tanggal selesai wajib dipilih.'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong.'), findsOneWidget);

    await tester.enterText(field('Nama Institusi'), '   ');
    await _tapSave(tester);
    await tester.pump();
    expect(find.text('Nama institusi tidak boleh kosong.'), findsOneWidget);

    await tester.enterText(field('Nama Institusi'), 'UI');
    await _tapSave(tester);
    await tester.pump();
    expect(find.text('Nama institusi minimal 3 karakter.'), findsOneWidget);

    await tester.enterText(
      field('Tautan Sertifikat (opsional)'),
      'bukan-url',
    );
    await _tapSave(tester);
    await tester.pump();
    expect(
      find.text('Tautan harus berupa URL http/https yang valid.'),
      findsOneWidget,
    );
  });

  testWidgets('Urutan tanggal selesai sebelum mulai ditolak', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await _pickDay(tester, 'Tanggal Mulai', '20');
    await _pickDay(tester, 'Tanggal Selesai', '5');

    await _tapSave(tester);
    await tester.pump();

    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
      findsOneWidget,
    );
  });

  testWidgets('Form menyimpan data yang valid', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await tester.enterText(
      field('Nama Institusi'),
      'Universitas Indonesia',
    );
    await tester.enterText(field('Jurusan'), 'Ilmu Komputer');
    await tester.enterText(
      field('Tautan Sertifikat (opsional)'),
      'https://example.com/sertifikat',
    );
    await tester.enterText(
      field('Deskripsi'),
      'Aktif dalam kegiatan kampus dan lomba.',
    );
    await _pickDay(tester, 'Tanggal Mulai', '20');
    await _pickDay(tester, 'Tanggal Selesai', '25');

    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pendidikan berhasil ditambahkan!'), findsOneWidget);
  });
}
