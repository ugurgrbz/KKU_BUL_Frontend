import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

// 🔹 Kayıt Sayfası
class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
  State<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _ogrenciNoController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  bool yukleniyor = false;
  String? hataMesaji;

  Future<void> _kayitOl() async {
    final ad = _adController.text.trim();
    final soyad = _soyadController.text.trim();
    final telefon = _telefonController.text.trim();
    final ogrenciNo = _ogrenciNoController.text.trim();
    final sifre = _sifreController.text.trim();

    if (ad.isEmpty ||
        soyad.isEmpty ||
        telefon.isEmpty ||
        ogrenciNo.isEmpty ||
        sifre.isEmpty) {
      setState(() {
        hataMesaji = "Lütfen tüm alanları doldurun";
      });
      return;
    }

    setState(() {
      yukleniyor = true;
      hataMesaji = null;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ogrenciNo": ogrenciNo,
          "sifre": sifre,
          "ad": ad,
          "soyad": soyad,
          "telefonNo": telefon,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kayıt başarılı. Giriş yapabilirsiniz.")),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          hataMesaji = response.body;
        });
      }
    } catch (_) {
      setState(() {
        hataMesaji = "Sunucuya bağlanılamadı";
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 ARKA PLAN
          Positioned.fill(
            child: Image.asset(
              'assets/giris_bgyeni.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌿 OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.05),
            ),
          ),

          // 📦 FORM
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 360, // 🔥 login ile aynı
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔹 Ad
                        TextField(
                          controller: _adController,
                          decoration: InputDecoration(
                            labelText: "Ad",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 🔹 Soyad
                        TextField(
                          controller: _soyadController,
                          decoration: InputDecoration(
                            labelText: "Soyad",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 🔹 Telefon
                        TextField(
                          controller: _telefonController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Telefon Numarası",
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 🔹 Öğrenci No
                        TextField(
                          controller: _ogrenciNoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Öğrenci Numarası",
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 🔹 Şifre
                        TextField(
                          controller: _sifreController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Şifre",
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // 🔹 Kayıt Ol
                        ElevatedButton(
                          onPressed: yukleniyor ? null : _kayitOl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 55, 192, 114),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: yukleniyor
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Kayıt Ol",
                                  style: TextStyle(fontSize: 16,
                                   color: Colors.white)

                                ),
                        ),

                        // 🔹 Hata
                        if (hataMesaji != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            hataMesaji!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
