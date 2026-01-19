import 'package:flutter/material.dart';
import 'package:kampus_app/sayfalar/profil_sayfasi.dart';
import 'package:provider/provider.dart';
import 'duyurular_sayfasi.dart';
import 'esya_bildir.dart';
import 'esya_listesi.dart';
import '../state/user_state.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>();

    // Senin yeşil rengin (Resmin arka planıyla aynı olan kod)
    final Color anaYesil = const Color.fromARGB(255, 96, 159, 99);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🟢 1. MODERN HEADER (Sabit Alan)
          Container(
            padding: const EdgeInsets.only(
              top: 45,
              left: 20,
              right: 15,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              // DİKKAT: Gradient'i kaldırdım, direkt rengi verdim.
              // Böylece resmindeki yeşil ile buradaki yeşil birebir tutacak.
              color: anaYesil,

              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: anaYesil.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 👋 SOL TARAF: İSİM
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Hoş geldin,",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${user.ad} 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 🔍 SAĞ TARAF: BÜYÜK FOTOĞRAF
                Container(
                  // Boyutu 75'ten 95'e çıkardım, daha büyük duracak
                  height: 95,
                  child: Image.asset(
                    'assets/yeni_logo.png', // Arka planı yeşile boyadığın resim
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          // 🔲 2. KARTLAR ALANI
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // ÜST SATIR
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _menuKart(
                            baslik: "Kayıp Eşya\nBildir",
                            ikon: Icons.add_circle_outline,
                            temaRengi: const Color.fromARGB(255, 188, 39, 133),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EsyaBildirPage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _menuKart(
                            baslik: "Kayıp\nEşyalar",
                            ikon: Icons.search,
                            temaRengi: const Color(0xFF1E88E5),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EsyaListesiPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ALT SATIR
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _menuKart(
                            baslik: "Profil",
                            ikon: Icons.person,
                            temaRengi: const Color(0xFFF9A825),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const profil_sayfasi(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _menuKart(
                            baslik: "Duyurular",
                            ikon: Icons.notifications_active,
                            temaRengi: const Color(0xFFE53935),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DuyurularSayfasi(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⚪ KART TASARIMI (Değişmedi)
  Widget _menuKart({
    required String baslik,
    required IconData ikon,
    required Color temaRengi,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: temaRengi.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(ikon, size: 32, color: temaRengi),
              ),
              const SizedBox(height: 12),
              Text(
                baslik,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
