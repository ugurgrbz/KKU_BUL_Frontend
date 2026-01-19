import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../state/user_state.dart';

class TalepGonderPage extends StatefulWidget {
  final int esyaId;
  final String esyaAdi;

  const TalepGonderPage({
    super.key,
    required this.esyaId,
    required this.esyaAdi,
  });

  @override
  State<TalepGonderPage> createState() => _TalepGonderPageState();
}

class _TalepGonderPageState extends State<TalepGonderPage> {
  final TextEditingController aciklamaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _seciliFoto;
  bool yukleniyor = false;

  // 📸 FOTO SEÇ
  Future<void> _fotoSec() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto == null) return;

    setState(() {
      _seciliFoto = File(foto.path);
    });
  }

  // 📤 TALEP GÖNDER
  Future<void> _talepGonder() async {
    final ogrNo = context.read<UserState>().ogrenciNo;

    if (ogrNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oturum bilgisi bulunamadı")),
      );
      return;
    }

    if (aciklamaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Açıklama zorunlu")),
      );
      return;
    }

    setState(() => yukleniyor = true);

    try {
      String? fotoUrl;

      // 📸 FOTO SADECE SEÇİLDİYSE YÜKLENİR (OPSİYONEL)
      if (_seciliFoto != null) {
        fotoUrl = await ApiService.uploadFoto(_seciliFoto!);
      }

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/talep"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "esyaId": widget.esyaId,
          "talepEdenOgrenciNo": ogrNo,
          "talepAciklama": aciklamaController.text.trim(),
          "talepFotoUrl": fotoUrl, // 🔥 null olabilir
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Talep gönderildi")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sunucu hatası")),
      );
    } finally {
      if (mounted) setState(() => yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.esyaAdi)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: aciklamaController,
              decoration: const InputDecoration(
                labelText: "Sadece sahibinin bileceği bir açıklama talebi yazınız ",
              ),
            ),

            const SizedBox(height: 12),

            // 📸 SEÇİLEN FOTO (VARSA)
            if (_seciliFoto != null && !kIsWeb)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _seciliFoto!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 8),

            TextButton.icon(
              onPressed: _fotoSec,
              icon: const Icon(Icons.photo),
              label: const Text("Fotoğraf Ekle (Opsiyonel)"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: yukleniyor ? null : _talepGonder,
              child: yukleniyor
                  ? const CircularProgressIndicator()
                  : const Text("Talep Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
