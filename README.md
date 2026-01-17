# 🖱️ Aplikasi Peminjaman Mouse – UKK 2026

Dibuat oleh: **Zahra Amelia Wijayanti**
Project: **Aplikasi Manajemen Peminjaman Mouse menggunakan Flutter dan Supabase**.

## 🗄️ Dokumentasi Supabase

### Struktur Tabel `mouse`

Tabel ini menyimpan data utama aset mouse:

* **kode_aset**: Kode unik mouse.
* **merk**: Nama brand mouse.
* **tipe**: Jenis mouse (Wireless / Kabel / Gaming).
* **dpi**: Spesifikasi DPI mouse.
* **status**: Ketersediaan (Tersedia/Dipinjam).
* **image_url**: Link gambar mouse.

### Konfigurasi Keamanan (RLS)

* **Status**: Disabled (Non-aktif).
* **Tujuan**: Memudahkan proses penilaian UKK agar penguji dapat mengakses data tanpa kendala autentikasi.

### Integrasi Flutter

Aplikasi terhubung menggunakan `Supabase.instance.client` dengan URL dan Anon Key yang telah dikonfigurasi pada file `main.dart`.
