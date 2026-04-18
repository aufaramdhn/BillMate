# BillMate - Sprint Task Checklist

Gunakan checklist ini sebagai source of truth progres sprint.
Saat task selesai, ubah `[ ]` menjadi `[x]`.
Saat pindah chat, lanjutkan dari task unchecked tertinggi pada sprint aktif dan sebutkan task ID tersebut di awal prompt/response.

## Sprint 1 - Foundation (`sprint/s1-foundation`)

- [x] `S1-T01` Inisialisasi project Flutter + struktur folder Clean Architecture
- [x] `S1-T02` Setup konfigurasi `.env` (Supabase URL, anon key, OneSignal app id)
- [x] `S1-T03` Integrasi Supabase client di app startup
- [x] `S1-T04` Implementasi Auth email/password (login, register, logout)
- [x] `S1-T05` Implementasi Google OAuth via Supabase
- [x] `S1-T06` Simpan `onesignal_player_id` ke tabel `users` setelah login
- [x] `S1-T07` Setup routing dasar via `go_router`
- [x] `S1-T08` Setup theme light/dark sesuai design system
- [x] `S1-T09` Unit test dasar auth repository
- [x] `S1-T10` Sprint demo: user bisa login dan masuk dashboard

## Sprint 2 - Core Bills (`sprint/s2-bills`)

- [x] `S2-T01` Buat tabel `bills` + aktifkan RLS
- [x] `S2-T02` Implementasi `BillModel` + mapping entity
- [x] `S2-T03` Implementasi CRUD bills di repository
- [ ] `S2-T04` Implementasi `BillsBloc` (load/add/edit/delete)
- [ ] `S2-T05` Implementasi screen Dashboard
- [ ] `S2-T06` Implementasi screen Tambah Tagihan
- [ ] `S2-T07` Implementasi screen Detail Tagihan
- [ ] `S2-T08` Implementasi filter/sort (due date, kategori, status)
- [ ] `S2-T09` Implementasi aksi tandai lunas
- [ ] `S2-T10` Widget test untuk add form + bill card

## Sprint 3 - Notifikasi + Offline (`sprint/s3-notification-offline`)

- [ ] `S3-T01` Integrasi `flutter_local_notifications` + timezone
- [ ] `S3-T02` Jadwalkan notifikasi H-3, H-1, H-0 saat bill dibuat
- [ ] `S3-T03` Reschedule notifikasi saat bill diubah
- [ ] `S3-T04` Cancel notifikasi saat bill lunas/dihapus
- [ ] `S3-T05` Setup Hive box untuk cache bill offline
- [ ] `S3-T06` Implementasi strategi sync Hive -> Supabase saat online
- [ ] `S3-T07` Tambah `notifications_log` untuk audit jadwal/kirim
- [ ] `S3-T08` Unit test NotificationService
- [ ] `S3-T09` Integration test mode offline tambah tagihan
- [ ] `S3-T10` Validasi notifikasi muncul tepat waktu pada device test

## Sprint 4 - Rekap + Split Bill (`sprint/s4-recap-split`)

- [ ] `S4-T01` Implementasi query agregasi rekap bulanan
- [ ] `S4-T02` Implementasi screen Rekap + grafik `fl_chart`
- [ ] `S4-T03` Tambahkan tabel `split_groups` + `split_members` + RLS
- [ ] `S4-T04` Implementasi repository split group dan split member
- [ ] `S4-T05` Implementasi screen Split List
- [ ] `S4-T06` Implementasi screen Detail Split
- [ ] `S4-T07` Implementasi screen Buat Grup Split
- [ ] `S4-T08` Integrasi OneSignal push reminder ke anggota
- [ ] `S4-T09` Implementasi status bayar anggota split
- [ ] `S4-T10` Integration test end-to-end split bill flow

## Release Gate (wajib sebelum merge ke `main`)

- [ ] `REL-T01` Semua task Sprint 1-4 yang critical selesai
- [ ] `REL-T02` Semua test utama lulus (unit/widget/integration)
- [ ] `REL-T03` UAT minimal 5 skenario utama tanpa blocker
- [ ] `REL-T04` Checklist keamanan RLS selesai direview
- [ ] `REL-T05` Build Android beta berhasil dan siap rilis internal
