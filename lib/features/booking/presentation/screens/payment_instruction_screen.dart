// Path: lib/features/booking/presentation/screens/payment_instruction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard

// Anda mungkin ingin import CustomerHomeScreen untuk navigasi setelah selesai
// import '../../home/presentation/screens/customer_home_screen.dart'; // Sesuaikan path

class PaymentInstructionScreen extends StatelessWidget {
  final String bookingId; // ID booking yang baru dibuat
  final double totalPrice;  // Total harga yang harus dibayar

  // Informasi Rekening Bank (Hardcode dulu untuk MVP)
  // Nanti bisa diambil dari Appwrite (koleksi app_settings)
  static const String bankName = 'Bank Central Asia (BCA)';
  static const String accountNumber = '1234567890';
  static const String accountName = 'PT. Home Services Sejahtera';

  const PaymentInstructionScreen({
    super.key,
    required this.bookingId,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruksi Pembayaran'),
        automaticallyImplyLeading: false, // Sembunyikan tombol kembali default
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Icon(
                Icons.payment_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Text(
                'Pemesanan Berhasil!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'Booking ID: $bookingId', // Tampilkan Booking ID
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Silakan lakukan pembayaran sejumlah:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Rp ${totalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Ke rekening berikut:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            _buildPaymentDetailRow('Nama Bank:', bankName, context),
            _buildPaymentDetailRow('Nomor Rekening:', accountNumber, context, canCopy: true),
            _buildPaymentDetailRow('Atas Nama:', accountName, context),
            const SizedBox(height: 24.0),
            Text(
              'PENTING:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red[700]),
            ),
            const SizedBox(height: 4.0),
            const Text(
              '• Mohon transfer tepat sesuai jumlah di atas (hingga digit terakhir) untuk mempermudah verifikasi.\n'
              '• Setelah melakukan transfer, silakan unggah bukti pembayaran Anda melalui menu "Riwayat Pesanan".\n'
              '• Pesanan Anda akan diproses setelah pembayaran diverifikasi oleh Admin (biasanya dalam 1x24 jam kerja).',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0)
                ),
                onPressed: () {
                  // Navigasi kembali ke halaman utama atau riwayat pesanan
                  // Untuk sekarang, kita kembali ke CustomerHomeScreen
                   Navigator.of(context).pushNamedAndRemoveUntil(
                     '/customer_home', // Asumsi rute ini ada dan mengarah ke CustomerHomeScreen
                     (Route<dynamic> route) => false,
                   );
                },
                child: const Text('Saya Mengerti, Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, BuildContext context, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(value),
              if (canCopy)
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  tooltip: 'Salin Nomor Rekening',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nomor rekening disalin!')),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}