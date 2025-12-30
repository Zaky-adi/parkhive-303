import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/area_parkir_model.dart';

class ApiService {
  static const String _baseUrl =
      'https://trpl-303-park-hive.vercel.app/public/api';

  static const String _tokenKey = 'authToken';

  // ================= TOKEN =================

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null) {
      final response = await http.get(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('LOGOUT STATUS: ${response.statusCode}');
      print('LOGOUT BODY: ${response.body}');
    }

    // 🔥 HAPUS TOKEN LOKAL (WAJIB)
    await prefs.remove(_tokenKey);
  }

  // ================= LOGIN =================

  Future<bool> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'hash_sandi': password,
      }),
    );

    // 🔍 DEBUG
    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN BODY: ${response.body}');

    // ❌ Server kirim HTML
    if (response.body.trim().startsWith('<')) {
      throw Exception('Server mengembalikan HTML, API bermasalah.');
    }

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      await _saveToken(jsonResponse['access_token']);
      return true;
    } else {
      throw Exception(
          jsonResponse['message'] ?? 'Login gagal, periksa data Anda.');
    }
  }

  // ================= REGISTER =================

  Future<bool> registerUser(
    String nama,
    String email,
    String noHp,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      throw Exception('Kata sandi dan konfirmasi kata sandi tidak cocok.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nama_pengguna': nama,
        'email': email,
        'no_hp': noHp,
        'hash_sandi': password,
        'hash_sandi_confirmation': confirmPassword,
      }),
    );

    // 🔍 DEBUG
    print('REGISTER STATUS: ${response.statusCode}');
    print('REGISTER BODY: ${response.body}');

    // ❌ Server kirim HTML
    if (response.body.trim().startsWith('<')) {
      throw Exception(
          'Server mengembalikan HTML, endpoint API tidak berjalan.');
    }

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      String message = jsonResponse['message'] ?? 'Registrasi gagal.';

      if (jsonResponse['errors'] != null) {
        message = jsonResponse['errors'].values.first[0];
      }

      throw Exception(message);
    }
  }

  // ================= AMBIL AREA PARKIR =================
  Future<List<AreaParkirModel>> fetchAreaParkir() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$_baseUrl/areas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List list = jsonData['data'];
      return list.map((e) => AreaParkirModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data area parkir');
    }
  }

  // ================= KIRIM LAPORAN =================
  Future<void> kirimLaporan({
    required int areaId,
    required String tipeLaporan,
    required String detailLaporan,
    File? foto,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/laporan'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['area_id'] = areaId.toString();
    request.fields['tipe_laporan'] = tipeLaporan;
    request.fields['detail_laporan'] = detailLaporan;

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'url_foto_laporan',
          foto.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception(responseBody);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // ⬇️ AMBIL DATA YANG BENAR
      return jsonResponse['data'];
    } else {
      throw Exception('Gagal memuat profile');
    }
  }

  // ================= GET GENERIC =================
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    // Debug
    print('GET $endpoint STATUS: ${response.statusCode}');
    print('GET $endpoint BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data dari $endpoint');
    }
  }

  Future<List<dynamic>> getHadiah() async {
    final response = await get('/hadiah');

    if (response['status'] == 'success') {
      return response['data'];
    }
    return [];
  }

  Future<List<dynamic>> getHadiahSaya() async {
    final response = await get('/hadiah-saya');

    if (response['status'] == 'success') {
      return response['data'];
    }
    return [];
  }

  // ================= TUKAR HADIAH =================
  Future<void> tukarHadiah({
    required int hadiahId,
    int jumlah = 1,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$_baseUrl/hadiah/tukar/$hadiahId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'hadiah_id': hadiahId,
        'jumlah': jumlah,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal menukar hadiah');
    }
  }

  Future<void> claimBadge(int badgeId) async {
    final response = await post('/badges/$badgeId/claim');

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Gagal klaim badge');
    }
  }

  Future<void> claimLaporanPoin(int laporanId) async {
    final response = await post('/laporan/$laporanId/claim-poin');

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Gagal klaim poin laporan');
    }
  }

  // ================= HTTP HELPER =================

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body ?? {}),
    );

    if (response.body.trim().startsWith('<')) {
      throw Exception('Server mengembalikan HTML');
    }

    return jsonDecode(response.body);
  }
}
