import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';
import 'package:home_services/core/appwrite_client_service.dart';
import 'package:home_services/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/features/services_catalogue/data/models/service_model.dart';
import 'payment_instruction_screen.dart';
import 'package:intl/intl.dart';

class BookingFormScreen extends StatefulWidget {
  final ServiceModel selectedService;

  // Konstanta untuk Appwrite
  static const String databaseId = '683f95e1003c6576571c';
  static const String bookingsCollectionId = 'bookings';

  const BookingFormScreen({super.key, required this.selectedService});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];

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
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak valid, silakan login kembali.')),
      );
      setState(() { _isLoading = false; });
      return;
    }

    final String userId = authNotifier.currentUser!.$id;
    final String customerName = authNotifier.currentUser!.name;
    final String servicesIdValue = widget.selectedService.id;     
    final String servicesNameValue = widget.selectedService.name;   
    final double totalPrice = widget.selectedService.basePrice; 

    try {
      final String startTimeStr = _selectedTimeSlot!.split(' - ')[0];
      final bookingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(startTimeStr.split(':')[0]),
        int.parse(startTimeStr.split(':')[1]),
      );

      final documentData = {
        'userId': userId,
        'customerName': customerName,
        'servicesId': servicesIdValue,      
        'servicesName': servicesNameValue,
        'bookingAddrees': _addressController.text.trim(),
        'bookingDate': bookingDateTime.toIso8601String(),
        'bookingTimeSlot': _selectedTimeSlot,
        'notes': _notesController.text.trim(),
        'totalPrice': totalPrice,
        'paymentStatus': 'PENDING_PAYMENT',
        'bookingStatus': 'PENDING_ADMIN_CONFIRMATION',
      };

      final List<String> permissions = [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ];

      final newBooking = await appwrite.databases.createDocument(
        databaseId: BookingFormScreen.databaseId,
        collectionId: BookingFormScreen.bookingsCollectionId,
        documentId: ID.unique(),
        data: documentData,
        permissions: permissions,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentInstructionScreen(
              bookingId: newBooking.$id,
              totalPrice: totalPrice,
            ),
          ),
        );
      }

    } on AppwriteException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: ${e.message ?? "Terjadi kesalahan"}')),
        );
      }
    } catch (e) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesan Layanan',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Informasi Layanan
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cleaning_services,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selectedService.name,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${widget.selectedService.basePrice.toStringAsFixed(0)}',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.selectedService.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.selectedService.description,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                    if (widget.selectedService.estimatedDuration != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Estimasi: ${widget.selectedService.estimatedDuration}',
                            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Pemesanan
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pemesanan',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Alamat
                  Text(
                    'Alamat Lengkap',
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap layanan',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14
                      ),
                    ),
                    validator: (value) => 
                        (value == null || value.isEmpty) 
                            ? 'Alamat tidak boleh kosong' 
                            : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  
                  // Tanggal dan Waktu
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, 
                                        color: Colors.grey[600], size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedDate == null
                                          ? 'Pilih Tanggal'
                                          : DateFormat('dd MMM yyyy').format(_selectedDate!),
                                      style: TextStyle(
                                        color: _selectedDate == null 
                                            ? Colors.grey[500] 
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu',
                              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0
                                ),
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
                              validator: (value) => 
                                  (value == null) 
                                      ? 'Silakan pilih waktu' 
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Catatan
                  Text(
                    'Catatan Tambahan (Opsional)',
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Akses khusus, hewan peliharaan, dll.',
                      prefixIcon: const Icon(Icons.notes_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  
                  // Tombol Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: colorScheme.primary.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline),
                                const SizedBox(width: 12),
                                Text(
                                  'Konfirmasi Pesanan',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
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