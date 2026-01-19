import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class DuyurularSayfasi extends StatefulWidget {
  const DuyurularSayfasi({super.key});

  @override
  State<DuyurularSayfasi> createState() => _DuyurularSayfasiState();
}

class _DuyurularSayfasiState extends State<DuyurularSayfasi> {
  late Future<List<dynamic>> duyurularFuture;

  @override
  void initState() {
    super.initState();
    _yenidenYukle();
  }

  void _yenidenYukle() {
    duyurularFuture = _duyurulariGetir();
  }

  Future<List<dynamic>> _duyurulariGetir() async {
    final response =
        await http.get(Uri.parse("${ApiService.baseUrl}/api/duyurular"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Duyurular getirilemedi");
    }
  }

  Future<void> _tumunuTemizle() async {
    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/api/duyurular/temizle"),
    );

    if (response.statusCode == 200) {
      setState(() {
        _yenidenYukle();
      });
    }
  }

  void _temizlemeOnayi() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Duyuruları Temizle"),
        content: const Text("Tüm duyuruları silmek istiyor musun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _tumunuTemizle();
            },
            child: const Text("Temizle"),
          ),
        ],
      ),
    );
  }

  String _tarihFormatla(String tarih) {
    final dt = DateTime.parse(tarih);
    return "${dt.day}.${dt.month}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duyurular"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _temizlemeOnayi,
            tooltip: "Duyuruları Temizle",
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: duyurularFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu"));
          }

          final duyurular = snapshot.data!;

          if (duyurular.isEmpty) {
            return const Center(
              child: Text(
                "Henüz duyuru yok",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: duyurular.length,
            itemBuilder: (context, index) {
              final d = duyurular[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              d["baslik"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d["aciklama"] ?? "",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _tarihFormatla(d["tarih"]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
