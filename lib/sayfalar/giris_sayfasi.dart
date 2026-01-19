import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../state/user_state.dart';
import 'ana_sayfa.dart';
import 'kayit_sayfasi.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({super.key});

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController _ogrenciNoController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  String? hataMesaji;
  bool yukleniyor = false;

  void _girisYap() async {
    final ogrenciNo = _ogrenciNoController.text.trim();
    final sifre = _sifreController.text.trim();

    if (ogrenciNo.isEmpty || sifre.isEmpty) {
      setState(() {
        hataMesaji = "Öğrenci numarası ve şifre giriniz";
      });
      return;
    }

    setState(() {
      yukleniyor = true;
      hataMesaji = null;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ogrenciNo": ogrenciNo,
          "sifre": sifre,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        context.read<UserState>().setUser(
              ogrenciNo: data["ogrenciNo"],
              ad: data["ad"],
            );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnaSayfa()),
        );
      } else {
        setState(() {
          hataMesaji = "Giriş başarısız";
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🌿 ARKA PLAN
          Positioned.fill(
            child: Image.asset(
              'assets/giris_bgyeni.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌿 HAFİF KARARTI
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.05),
            ),
          ),

          // 📦 FORM + SAFEAREA
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
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
                          // 🔹 Öğrenci No
                          TextField(
                            controller: _ogrenciNoController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Öğrenci Numarası',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔹 Şifre
                          TextField(
                            controller: _sifreController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // 🔹 GİRİŞ BUTONU
                          ElevatedButton(
                            onPressed: yukleniyor ? null : _girisYap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 55, 192, 114),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          // 🔹 KAYIT OL
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const KayitSayfasi(),
                                ),
                              );
                            },
                            child:
                                const Text('Hesabın yok mu? Kayıt Ol'),
                          ),

                          // 🔹 HATA MESAJI
                          if (hataMesaji != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              hataMesaji!,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
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
