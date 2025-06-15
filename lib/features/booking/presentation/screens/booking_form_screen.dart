import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart'; // Untuk ID dan AppwriteException

import 'package:home_services/core/appwrite_client_service.dart';
import 'package:home_services/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/features/services_catalogue/data/models/service_model.dart';
import 'payment_instruction_screen.dart'; 

class BookingFormScreen extends StatefulWidget {
  final ServiceModel selectedService; // Menerima layanan yang dipilih

  const BookingFormScreen({super.key, required this.selectedService});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot; // Contoh slot waktu
  bool _isLoading = false;

  // Contoh slot waktu yang tersedia (ini bisa diambil dari backend nanti)
  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];

  // Definisikan ID Database dan Koleksi Bookings
  // GANTI DENGAN ID ANDA!
  static const String _databaseId = '683f95e1003c6576571c'; // ID Database Anda
  static const String _bookingsCollectionId = 'bookings'; // ID Koleksi bookings Anda

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)), // Tidak bisa pesan untuk hari ini atau lampau
      lastDate: DateTime.now().add(const Duration(days: 30)), // Batas pemesanan 30 hari ke depan
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, jangan lanjutkan
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal layanan.')),
      );
      return;
    }
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih slot waktu layanan.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final appwrite = context.read<AppwriteClientService>();
    final authNotifier = context.read<AuthNotifier>();

    if (!authNotifier.isLoggedIn || authNotifier.currentUser == null) {
      // Seharusnya tidak terjadi jika alur sudah benar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak valid, silakan login kembali.')),
      );
      setState(() { _isLoading = false; });
      return;
    }

    final String userId = authNotifier.currentUser!.$id;
    final String customerName = authNotifier.currentUser!.name; // Denormalisasi
    final String servicesId = widget.selectedService.id;
    final String servicesName = widget.selectedService.name; // Denormalisasi
    final double totalPrice = widget.selectedService.basePrice; // Untuk MVP, harga sama dengan basePrice

    try {
      // Gabungkan tanggal dan waktu (ambil jam awal dari slot waktu)
      // Ini contoh sederhana, mungkin perlu parsing yang lebih baik untuk _selectedTimeSlot
      final String startTimeStr = _selectedTimeSlot!.split(' - ')[0]; // Ambil "08:00"
      final bookingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(startTimeStr.split(':')[0]), // Jam
        int.parse(startTimeStr.split(':')[1]), // Menit
      );


      final documentData = {
        'userId': userId,
        'customerName': customerName,
        'servicesId': servicesId,
        'servicesName': servicesName,
        'bookingAddrees': _addressController.text.trim(),
        'bookingDate': bookingDateTime.toIso8601String(), // Simpan sebagai ISO 8601 String
        'bookingTimeSlot': _selectedTimeSlot,
        'notes': _notesController.text.trim(),
        'totalPrice': totalPrice,
        'paymentStatus': 'PENDING_PAYMENT', // Status awal
        'bookingStatus': 'PENDING_ADMIN_CONFIRMATION', // Status awal
        // 'assignedCleanerId': null, // Opsional
        // 'adminNotes': null, // Opsional
      };

      print('[BOOKING] Data yang akan dibuat: $documentData');

      // Siapkan Document Level Permissions
      final List<String> permissions = [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)), // Customer bisa update (misal, cancel)
        Permission.delete(Role.user(userId)), // Opsional
        //Permission.read(Role.team('admins')),
        //Permission.update(Role.team('admins')),
        //Permission.delete(Role.team('admins')),
      ];


      final newBooking = await appwrite.databases.createDocument(
        databaseId: _databaseId,
        collectionId: _bookingsCollectionId,
        documentId: ID.unique(), // Biarkan Appwrite generate ID unik untuk booking
        data: documentData,
        permissions: permissions,
      );

      print('Booking berhasil dibuat: ${newBooking.$id}');
      if (mounted) {
              Navigator.of(context).pushReplacement( // pushReplacement agar tidak bisa kembali ke form booking
          MaterialPageRoute(
            builder: (context) => PaymentInstructionScreen(
              bookingId: newBooking.$id, // Kirim ID booking baru
              totalPrice: totalPrice,    // Kirim total harga
            ),
          ),
        );
      }

    } on AppwriteException catch (e) {
      print('Error membuat booking: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: ${e.message ?? "Terjadi kesalahan"}')),
        );
      }
    } catch (e) {
      print('Error tidak diketahui saat membuat booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan tidak diketahui: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan: ${widget.selectedService.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Layanan: ${widget.selectedService.name}', style: Theme.of(context).textTheme.titleLarge),
              Text('Harga: Rp ${widget.selectedService.basePrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap Layanan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Alamat tidak boleh kosong' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pilih Tanggal Layanan'
                    // Jika ingin format YYYY-MM-DD (memerlukan import 'package:intl/intl.dart';)
                    // : 'Tanggal: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                    // Atau format sederhana tanpa intl:
                    : 'Tanggal: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.grey.shade400)),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih Slot Waktu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time_outlined)
                ),
                value: _selectedTimeSlot,
                hint: const Text('Pilih Waktu'),
                isExpanded: true,
                items: _timeSlots.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimeSlot = newValue;
                  });
                },
                validator: (value) => (value == null) ? 'Slot waktu tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Konfirmasi Pesanan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16.0),
                      ),
                      onPressed: _isLoading ? null : _submitBooking,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}