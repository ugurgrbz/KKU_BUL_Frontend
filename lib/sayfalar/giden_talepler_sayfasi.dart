import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../state/user_state.dart';

class giden_talepler_sayfasi extends StatefulWidget {
  const giden_talepler_sayfasi({super.key});

  @override
  State<giden_talepler_sayfasi> createState() => _giden_talepler_sayfasiState();
}

class _giden_talepler_sayfasiState extends State<giden_talepler_sayfasi> {
  late Future<List<dynamic>> gidenTalepler;

  @override
  void initState() {
    super.initState();
    _yenidenYukle();
  }

  void _yenidenYukle() {
    final kullanici = context.read<UserState>();
    gidenTalepler = _talepleriGetir(
      "${ApiService.baseUrl}/api/talep/giden/${kullanici.ogrenciNo}",
    );
  }

  Future<List<dynamic>> _talepleriGetir(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Giden talepler getirilemedi");
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
            )
          ],
        ),
      ),
    );
  }

  Future<void> _talepSil(int talepId) async {
    final kullanici = context.read<UserState>();

    final response = await http.delete(
      Uri.parse(
        "${ApiService.baseUrl}/api/talep/$talepId/${kullanici.ogrenciNo}",
      ),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Talep silindi")));

      setState(() {
        _yenidenYukle();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.body)));
    }
  }

  void _silmeOnayiGoster(int talepId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Talebi Sil"),
        content: const Text("Bu talebi silmek istiyor musun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _talepSil(talepId);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
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
        title: const Text("Giden Taleplerim"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: gidenTalepler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu"));
          }

          final talepler = snapshot.data!;

          if (talepler.isEmpty) {
            return const Center(child: Text("Giden talep yok"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: talepler.length,
            itemBuilder: (context, index) {
              final talep = talepler[index];
              final String durum = talep["durum"]?.toString() ?? "Beklemede";
              final String? fotoUrl = talep["talepFotoUrl"];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(
                        talep["esyaAdi"] ?? "Eşya",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        talep["talepAciklama"] ?? "Açıklama yok",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        durum,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _durumRenk(durum),
                        ),
                      ),
                    ),

                    // 📸 FOTO VARSA GÖSTER
                    if (fotoUrl != null && fotoUrl.isNotEmpty)
                      GestureDetector(
                        onTap: () => _fotoBuyut(fotoUrl),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fotoUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                    // 🗑 SADECE KABUL DEĞİLSE
                    if (durum != "Kabul")
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.delete),
                            label: const Text("Talebi Sil"),
                            onPressed: () => _silmeOnayiGoster(talep["id"]),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
