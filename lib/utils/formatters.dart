import 'package:intl/intl.dart';

/// Kelas [Formatters] berisi fungsi-fungsi bantuan untuk mengubah format data 
/// mentah menjadi format yang ramah dibaca oleh user (UI).
class Formatters {
  
  /// Method statis untuk memformat angka double menjadi format Rupiah.
  /// Contoh: 680000 menjadi "Rp 680.000"
  static String formatRupiah(double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Membutuhkan package 'intl'
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  /// Method statis untuk memformat string tanggal ISO dari API menjadi format rapi.
  /// Contoh: "2025-06-28T10:00:00Z" menjadi "28 Jun 2025"
  static String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      return formatter.format(date);
    } catch (e) {
      // Jika terjadi kesalahan parsing tanggal, kembalikan string aslinya
      return dateString;
    }
  }
}