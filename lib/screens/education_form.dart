import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir untuk menambah bagian portofolio "Pendidikan".
/// Bagian ini dipilih karena memiliki atribut tanggal dan tautan,
/// sehingga validasi urutan tanggal dan format URL dapat didemonstrasikan.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _certificateUrlController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _degree = 'S1';

  final List<String> _degrees = const ['D3', 'S1', 'S2', 'S3'];

  @override
  void dispose() {
    _institutionController.dispose();
    _majorController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _certificateUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brown, width: 2),
      ),
    );
  }

  /// Menolak isian kosong, hanya spasi, dan panjang di luar batas.
  String? _validateText(
    String? value,
    String label, {
    int min = 3,
    int max = 100,
  }) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong.';
    if (text.length < min) return '$label minimal $min karakter.';
    if (text.length > max) return '$label maksimal $max karakter.';
    return null;
  }

  /// Tautan bersifat opsional, tetapi jika diisi harus http/https valid.
  String? _validateUrl(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final Uri? uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Tautan harus berupa URL http/https yang valid.';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        (isStart ? _startDate : _endDate) ?? DateTime(now.year - 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 5),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
        // Tanggal selesai yang lama dibatalkan jika sekarang sebelum mulai.
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          _endDateController.clear();
        }
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _institutionController.clear();
    _majorController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _certificateUrlController.clear();
    _descriptionController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
      _degree = 'S1';
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Pendidikan berhasil ditambahkan!',
            style: TextStyle(color: AppColors.brown),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institusi: ${_institutionController.text.trim()}'),
                Text('Jenjang: $_degree'),
                Text('Jurusan: ${_majorController.text.trim()}'),
                Text('Mulai: ${_startDateController.text}'),
                Text('Selesai: ${_endDateController.text}'),
                Text('Tautan: ${_certificateUrlController.text.trim()}'),
                Text('Deskripsi: ${_descriptionController.text.trim()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
              child: const Text('OK', style: TextStyle(color: AppColors.brown)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text(
          'Add Education Form',
          style: TextStyle(color: AppColors.cream, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.brown,
        iconTheme: const IconThemeData(color: AppColors.cream),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Menambah padding bawah sebesar tinggi papan ketik agar
            // tombol Simpan tetap dapat dijangkau saat keyboard muncul.
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _institutionController,
                  decoration: _decoration(
                    'Nama Institusi',
                    hint: 'Contoh: Universitas Indonesia',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      _validateText(value, 'Nama institusi', max: 100),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _degree,
                  decoration: _decoration('Jenjang'),
                  items: _degrees.map((String degree) {
                    return DropdownMenuItem<String>(
                      value: degree,
                      child: Text(degree),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() => _degree = value ?? 'S1');
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Jenjang wajib dipilih.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _majorController,
                  decoration: _decoration(
                    'Jurusan',
                    hint: 'Contoh: Ilmu Komputer',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateText(value, 'Jurusan', max: 100),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: _decoration(
                    'Tanggal Mulai',
                    hint: 'Pilih tanggal mulai',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.brown,
                    ),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (value) => _startDate == null
                      ? 'Tanggal mulai wajib dipilih.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: _decoration(
                    'Tanggal Selesai',
                    hint: 'Pilih tanggal selesai',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.brown,
                    ),
                  ),
                  onTap: () => _pickDate(isStart: false),
                  validator: (value) {
                    if (_endDate == null) {
                      return 'Tanggal selesai wajib dipilih.';
                    }
                    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                      return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _certificateUrlController,
                  decoration: _decoration(
                    'Tautan Sertifikat (opsional)',
                    hint: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _decoration(
                    'Deskripsi',
                    hint: 'Ringkasan kegiatan dan pencapaian',
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      _validateText(value, 'Deskripsi', min: 10, max: 500),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose,
                    foregroundColor: AppColors.brown,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
