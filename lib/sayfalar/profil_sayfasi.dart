import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/user_state.dart';
import 'gelen_talepler_sayfasi.dart';
import 'giden_talepler_sayfasi.dart';
import 'giris_sayfasi.dart'; // 👈 kendi giriş sayfan

class profil_sayfasi extends StatelessWidget {
  const profil_sayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final kullanici = context.watch<UserState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(kullanici.ad ?? ""),
              subtitle: Text("Öğrenci No: ${kullanici.ogrenciNo}"),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.inbox),
              title: const Text("Gelen Taleplerim"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const gelen_talepler_sayfasi(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.send),
              title: const Text("Giden Taleplerim"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const giden_talepler_sayfasi(),
                  ),
                );
              },
            ),

            const Spacer(),

            // 🚪 ÇIKIŞ YAP (EN ALTA SABİT)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Çıkış Yap",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // 1️⃣ Kullanıcı bilgisini temizle
                  context.read<UserState>().logout();

                  // 2️⃣ Tüm sayfaları kapat → Giriş sayfasına git
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GirisSayfasi(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
