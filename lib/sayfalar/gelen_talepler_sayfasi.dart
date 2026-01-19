import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../state/user_state.dart';

class gelen_talepler_sayfasi extends StatefulWidget {
  const gelen_talepler_sayfasi({super.key});

  @override
  State<gelen_talepler_sayfasi> createState() =>
      _gelen_talepler_sayfasiState();
}

class _gelen_talepler_sayfasiState
    extends State<gelen_talepler_sayfasi> {
  late Future<List<dynamic>> gelenTalepler;

  @override
  void initState() {
    super.initState();
    _yenidenYukle();
  }

  void _yenidenYukle() {
    final kullanici = context.read<UserState>();

    gelenTalepler = _talepleriGetir(
      "${ApiService.baseUrl}/api/talep/gelen/${kullanici.ogrenciNo}",
    );
  }

  Future<List<dynamic>> _talepleriGetir(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gelen talepler getirilemedi");
    }
  }

  // 🔍 FOTO TAM EKRAN
  void _fotoBuyut(String fotoUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(fotoUrl),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _talepKabulEt(int talepId) async {
    await http.put(
      Uri.parse("${ApiService.baseUrl}/api/talep/kabul/$talepId"),
    );

    setState(() {
      _yenidenYukle();
    });
  }

  Future<void> _talepReddet(int talepId) async {
    await http.put(
      Uri.parse("${ApiService.baseUrl}/api/talep/red/$talepId"),
    );

    setState(() {
      _yenidenYukle();
    });
  }

  Future<void> _iletisimBilgisiGoster(int talepId) async {
    final kullanici = context.read<UserState>();

    final response = await http.get(
      Uri.parse(
        "${ApiService.baseUrl}/api/talep/$talepId/${kullanici.ogrenciNo}/iletisim",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("İletişim Bilgileri"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📞 Talep Eden: ${data["talepEdenTelefon"] ?? "-"}"),
              const SizedBox(height: 8),
              Text("📞 Eşya Sahibi: ${data["esyaSahibiTelefon"] ?? "-"}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kapat"),
            ),
          ],
        ),
      );
    }
  }

  Color _durumRenk(String durum) {
    if (durum == "Kabul") return Colors.green;
    if (durum == "Reddedildi") return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelen Taleplerim"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: gelenTalepler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu"));
          }

          final talepler = snapshot.data!;

          if (talepler.isEmpty) {
            return const Center(child: Text("Gelen talep yok"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: talepler.length,
            itemBuilder: (context, index) {
              final talep = talepler[index];
              final String durum =
                  talep["durum"]?.toString() ?? "Beklemede";
              final String? fotoUrl = talep["talepFotoUrl"];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📸 FOTO (VARSA) → TIKLANINCA BÜYÜR
                      if (fotoUrl != null && fotoUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () => _fotoBuyut(fotoUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fotoUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  height: 160,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) {
                                return const SizedBox(
                                  height: 160,
                                  child: Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      if (fotoUrl != null && fotoUrl.isNotEmpty)
                        const SizedBox(height: 12),

                      Text(
                        "Talep Eden: ${talep["talepEdenOgrenciNo"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),
                      Text(talep["talepAciklama"] ?? ""),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Durum: "),
                          Text(
                            durum,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _durumRenk(durum),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 🔹 BEKLEMEDE → KABUL / RED
                      if (durum == "Beklemede")
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () =>
                                    _talepKabulEt(talep["id"]),
                                child: const Text("Kabul Et"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () =>
                                    _talepReddet(talep["id"]),
                                child: const Text("Reddet"),
                              ),
                            ),
                          ],
                        ),

                      // 📞 SADECE KABUL EDİLDİYSE
                      if (durum == "Kabul")
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.phone),
                              label:
                                  const Text("İletişim Bilgilerini Gör"),
                              onPressed: () =>
                                  _iletisimBilgisiGoster(talep["id"]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
