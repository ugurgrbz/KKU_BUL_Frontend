import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../state/user_state.dart';
import 'talep_gonder.dart';

class EsyaListesiPage extends StatefulWidget {
  const EsyaListesiPage({super.key});

  @override
  State<EsyaListesiPage> createState() => _EsyaListesiPageState();
}

class _EsyaListesiPageState extends State<EsyaListesiPage> {
  late Future<List<dynamic>> _futureEsyalar;

  @override
  void initState() {
    super.initState();
    _futureEsyalar = _esyalariGetir();
  }

  Future<List<dynamic>> _esyalariGetir() async {
    final response =
        await http.get(Uri.parse("${ApiService.baseUrl}/api/esya"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Eşyalar getirilemedi");
    }
  }

  // 🔹 EŞYA DETAY (AÇIKLAMA GÖSTEREN KISIM)
  void _esyaDetayGoster(dynamic esya) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              esya["esyaAdi"] ?? "Bilinmeyen Eşya",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text("📍 Konum: ${esya["konum"] ?? "-"}"),
            const SizedBox(height: 12),
            Text(
              "📝 Açıklama:\n${esya["aciklama"] ?? "Açıklama yok"}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _esyaSil(int id) async {
  final kullanici = context.read<UserState>();

  final response = await http.delete(
    Uri.parse(
      "${ApiService.baseUrl}/api/esya/$id/${kullanici.ogrenciNo}",
    ),
  );

  if (response.statusCode == 200) {
    setState(() {
      _futureEsyalar = _esyalariGetir();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Eşya silindi")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Eşya silinemedi")),
    );
  }
}


  void _silmeOnayiGoster(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eşyayı Sil"),
        content: const Text("Bu eşyayı silmek istiyor musun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _esyaSil(id);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>();
    final aktifOgrenciNo = user.ogrenciNo!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıp Eşyalar"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureEsyalar,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu"));
          }

          final esyalar = snapshot.data!;

          if (esyalar.isEmpty) {
            return const Center(
              child: Text("Henüz bildirilen eşya yok"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: esyalar.length,
            itemBuilder: (context, index) {
              final esya = esyalar[index];
              final benimEsyam =
                  esya["ogrenciNo"] == aktifOgrenciNo;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(esya["esyaAdi"] ?? ""),
                      subtitle: Text("📍 ${esya["konum"] ?? "-"}"),

                      // 🔥 EŞYAYA TIKLAYINCA AÇIKLAMA AÇILIR
                      onTap: () => _esyaDetayGoster(esya),

                      // 🗑️ SADECE SAHİBİ SİLER
                      trailing: benimEsyam
                          ? IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  _silmeOnayiGoster(esya["id"]),
                            )
                          : null,
                    ),

                    if (!benimEsyam)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.orange.shade700,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TalepGonderPage(
                                    esyaId: esya["id"],
                                    esyaAdi:
                                        esya["esyaAdi"] ?? "",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Bu eşya benim olabilir",
                              style:
                                  TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Bu eşya size ait",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
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
