# tugasbesar_2306035

# 🌸 Bloom - Lifestyle E-Commerce App

Aplikasi Bloom adalah platform e-commerce bergaya lifestyle boutique yang dikembangkan menggunakan Flutter. Aplikasi ini terintegrasi penuh dengan REST API dan dilengkapi dengan fitur manajemen state dinamis, Dark Mode, serta kalkulasi keranjang belanja yang presisi.

# Identitas Mahasiswa

Nama: Aghniya Afiatul Jannah

NIM: 2306035

Kelas: Kelas B

Mata Kuliah: Praktikum Pemrograman Mobile 2026

# Screenshot Aplikasi

(Catatan: Gambar di bawah ini diambil dari folder screenshots/. Pastikan Anda meletakkan file gambar di dalam folder tersebut).

Keterangan (Dari kiri ke kanan): Login Screen, Home Screen, Product Detail, Cart Screen (dengan Checkbox & Kalkulasi Grand Total), Profile Screen (Mode Gelap).

# Daftar Fitur yang Diimplementasikan

Aplikasi ini mencakup seluruh fitur yang diinstruksikan dalam rubrik UAS, beserta beberapa peningkatan logika frontend:

Autentikasi (API & Provider):

Register pengguna baru (dengan validasi format Email & Password).

Login dan penyimpanan Bearer Token menggunakan SharedPreferences.

Auto-login (Cek token aktif di Splash Screen).

Katalog Produk & Home:

Menampilkan daftar kategori dan produk dari API.

Fitur Pencarian (Search Bar) dan Penyortiran (Sort by Newest/Price).

Frontend Filtering cerdas (Menyaring produk yang tidak sesuai dengan Chips Kategori).

Detail Produk & Ulasan:

Menampilkan detail lengkap produk (Harga, Deskripsi, Gambar).

Daftar Review (Ulasan) dinamis dari API.

Kalkulasi Bintang/Rating otomatis berdasarkan total ulasan.

Fitur Tambah Ulasan (POST) dan Hapus Ulasan sendiri (DELETE).

Keranjang Belanja (Cart):

Integrasi Add to Cart dari layar Detail Produk.

Fitur ubah kuantitas (Plus/Minus) dan hapus (Trash) item di keranjang.

Fitur Checkbox Lokal: Memilih spesifik barang mana yang ingin di-checkout, Grand Total hanya menghitung barang yang dicentang.

Checkout & Riwayat Pesanan (Order):

Proses penempatan pesanan (POST) beserta Order Notes dan Shipping Address.

Riwayat Pesanan dengan pengelompokkan status (Pending, Processing, Delivered dll) beserta color-coding.

Menampilkan detail pesanan (Subtotal per barang & Grand Total).

Profil & Wishlist:

Edit profil (Nama, Nomor HP, Avatar) menggunakan metode PUT (Mengabaikan nilai null jika tidak diubah).

Fitur Wishlist menggunakan SharedPreferences yang disimpan secara unik per ID User.

Sistem Tema Cerdas (Dark Mode):

Dukungan Light Mode (Warm Ivory) dan Dark Mode (Deep Charcoal).

Warna komponen (Card, Text, Form Input, Appbar) beradaptasi secara otomatis (Bunglon) dengan mendengarkan ThemeProvider secara global di seluruh layar aplikasi.

# Cara Menjalankan Aplikasi
Sebelum menjalankan, file apk dapat diakses melalui link https://bit.ly/4fpOXgu
Ikuti langkah-langkah berikut untuk menjalankan aplikasi Bloom di local machine Anda:

Prasyarat:

Pastikan Flutter SDK sudah terinstal (disarankan versi 3.10.0 atau ke atas).

Pastikan Emulator Android/iOS sudah berjalan, atau gunakan perangkat fisik yang terhubung menggunakan USB Debugging.

Langkah Instalasi:

Buka terminal/command prompt dan masuk ke direktori project ini.

Jalankan perintah berikut untuk mengunduh semua paket (dependencies) yang dibutuhkan:

```flutter pub get```


(Opsional jika menggunakan VS Code) Jika Anda baru saja berpindah dari web (Chrome) ke Emulator/HP, sangat disarankan untuk membersihkan cache terlebih dahulu:

```flutter clean```
```flutter pub get```


Jalankan aplikasi dengan perintah:

```flutter run```


(Atau cukup tekan tombol F5 pada VS Code).

Tunggu beberapa saat (proses kompilasi pertama kali oleh Gradle mungkin memakan waktu 2-5 menit tergantung spesifikasi RAM laptop Anda).


