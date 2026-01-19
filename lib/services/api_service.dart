import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🌍 ARTIK TEK BİR ADRESİMİZ VAR (Hetzner Sunucusu)
  // Docker 80 portuna yönlendirdiği için port yazmaya gerek yok.
  static const String baseUrl = "http://46.224.178.32";

  // 📸 FOTO YÜKLEME FONKSİYONU
  static Future<String?> uploadFoto(File file) async {
    try {
      final uri = Uri.parse("$baseUrl/api/upload");
      final request = http.MultipartRequest("POST", uri);

      // Dosyayı ekle
      request.files.add(
        await http.MultipartFile.fromPath("file", file.path),
      );

      // İsteği gönder
      final response = await request.send();

      // 🔍 LOGLAR (Konsoldan takip etmen için)
      print("📤 UPLOAD STATUS: ${response.statusCode}");
      
      final responseBody = await response.stream.bytesToString();
      print("📤 UPLOAD BODY: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        // Backend hangi formatta dönerse dönsün yakala
        if (data["fotoUrl"] != null) return data["fotoUrl"];
        if (data["url"] != null) return data["url"];
        if (data["path"] != null) return data["path"];
      }
    } catch (e) {
      print("❌ HATA OLUŞTU: $e");
    }

    return null;
  }
}