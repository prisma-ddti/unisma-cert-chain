# UNISMA CACert

Repository ini menyediakan file `cacert-unisma.ac.id.pem` untuk membantu browser mengenali certificate chain domain `unisma.ac.id` dan subdomainnya. Gunakan file ini jika browser menampilkan error SSL/certificate saat membuka situs UNISMA, misalnya:

> [!NOTE]
> File cacert-unisma.ac.id.pem bukan _private key_. Isinya adalah CA certificate yang dibutuhkan browser untuk memverifikasi koneksi HTTPS.

Pilihan file:

- `cacert-unisma.ac.id.pem`: bundle berisi 2 certificate untuk Firefox dan workflow lama.
- `cacert-unisma.ac.id.chromium.pem`: file berisi 1 certificate untuk Chromium jika muncul pesan import hanya mendukung satu certificate.

## Google Chrome

Google Chrome biasanya memakai certificate store milik sistem operasi. Jadi cara import tergantung OS yang digunakan.

### Windows

1. Download `cacert-unisma.ac.id.pem`.
2. Buka Start Menu.
3. Cari dan buka `Manage user certificates`.
4. Masuk ke `Trusted Root Certification Authorities > Certificates`.
5. Klik kanan area kosong, lalu pilih `All Tasks > Import`.
6. Pilih file `cacert-unisma.ac.id.pem`.
7. Jika file tidak terlihat, ubah filter file menjadi `All Files`.
8. Pilih `Place all certificates in the following store`.
9. Pastikan store yang dipilih adalah `Trusted Root Certification Authorities`.
10. Selesaikan wizard import.
11. Restart Google Chrome.
12. Buka kembali situs UNISMA.

Alternatif melalui PowerShell sebagai Administrator: jalankan `certutil -addstore -f Root .\cacert-unisma.ac.id.pem`.

### macOS

1. Download `cacert-unisma.ac.id.pem`.
2. Buka aplikasi `Keychain Access`.
3. Pilih keychain `System` atau `login`.
4. Import file `cacert-unisma.ac.id.pem`.
5. Buka certificate yang baru diimport.
6. Pada bagian `Trust`, ubah `When using this certificate` menjadi `Always Trust`.
7. Tutup dialog dan masukkan password macOS jika diminta.
8. Restart Google Chrome.
9. Buka kembali situs UNISMA.

### Linux

Cara paling mudah adalah lewat halaman certificate Chrome.

1. Buka `chrome://settings/certificates`.
2. Buka tab `Authorities`.
3. Klik `Import`.
4. Pilih file `cacert-unisma.ac.id.pem`.
5. Jika Chromium menampilkan pesan `Import is only supported for a single certificate`, gunakan `cacert-unisma.ac.id.chromium.pem`.
6. Aktifkan trust untuk website jika diminta.
7. Restart Google Chrome.
8. Buka kembali situs UNISMA.

Jika Chrome/Chromium di Linux tetap belum membaca certificate, import lewat trust store distro yang digunakan atau hubungi admin sistem.

## Mozilla Firefox

Firefox dapat memakai certificate store sistem, tetapi cara paling mudah untuk end-user adalah import langsung dari pengaturan Firefox.

1. Download `cacert-unisma.ac.id.pem`.
2. Buka Firefox.
3. Buka menu `Settings > Privacy & Security`.
4. Scroll ke bagian `Certificates`.
5. Klik `View Certificates`.
6. Buka tab `Authorities`.
7. Klik `Import`.
8. Pilih file `cacert-unisma.ac.id.pem`.
9. Jika muncul pilihan trust, centang `Trust this CA to identify websites`.
10. Klik `OK`.
11. Restart Firefox.
12. Buka kembali situs UNISMA.

Jika Firefox memakai certificate store sistem, pastikan opsi `Allow Firefox to automatically trust third-party root certificates you install` aktif di `Settings > Privacy & Security > Certificates`.

## Membuat Ulang File PEM

File `.pem` sudah tersedia di repository ini. Script hanya diperlukan jika certificate chain berubah dan file perlu dibuat ulang.

Jalankan `./generate.sh`.

Script membuat dua file:

- `cacert-unisma.ac.id.pem`
- `cacert-unisma.ac.id.chromium.pem`

## Catatan

- File ini adalah workaround di sisi pengguna.
- Perbaikan server-side yang benar tetap memasang `fullchain.pem` pada web server.
