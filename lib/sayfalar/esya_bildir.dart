import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../state/user_state.dart';

class EsyaBildirPage extends StatefulWidget {
  const EsyaBildirPage({super.key});

  @override
  State<EsyaBildirPage> createState() => _EsyaBildirPageState();
}

class _EsyaBildirPageState extends State<EsyaBildirPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController adController = TextEditingController();
  final TextEditingController aciklamaController = TextEditingController();
  final TextEditingController konumController = TextEditingController();

  bool yukleniyor = false;

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔥 GLOBAL STATE’TEN OGR NO AL
    final ogrenciNo = context.read<UserState>().ogrenciNo;

    if (ogrenciNo == null) {
      _hataGoster("Oturum bilgisi bulunamadı");
      return;
    }

    setState(() {
      yukleniyor = true;
    });

    final url = Uri.parse("${ApiService.baseUrl}/api/esya");

    try {
      final body = {
        "ogrenciNo": ogrenciNo,
        "esyaAdi": adController.text.trim(),
        "aciklama": aciklamaController.text.trim(),
        "konum": konumController.text.trim(),
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Başarılı"),
            content: const Text("Eşya başarıyla bildirildi."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Tamam"),
              ),
            ],
          ),
        );

        adController.clear();
        aciklamaController.clear();
        konumController.clear();
      } else {
        _hataGoster(response.body.toString());
      }
    } catch (_) {
      _hataGoster("Sunucuya bağlanılamadı");
    }

    setState(() {
      yukleniyor = false;
    });
  }

  void _hataGoster(String mesaj) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hata"),
        content: Text(mesaj),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 ARKA PLAN
          Positioned.fill(
            child: Image.asset(
              'assets/arka_plan.png',
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
  child: Padding(
    padding: const EdgeInsets.only(bottom: 110), // 
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 360,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: adController,
                    decoration: InputDecoration(
                      labelText: "Eşya Adı",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Zorunlu alan"
                            : null,
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: aciklamaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Açıklama",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: konumController,
                    decoration: InputDecoration(
                      labelText: "Bulunan Konum",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Zorunlu alan"
                            : null,
                  ),

                  const SizedBox(height: 22),

                  ElevatedButton(
                    onPressed: yukleniyor ? null : _kaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 119, 188, 123),
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
                                  "Kaydet",
                                  style: TextStyle(fontSize: 16,
                                   color: Colors.white)

                                ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),


          // 🔝 ÜST GERİ BUTONU
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Eşya Bildir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
}
