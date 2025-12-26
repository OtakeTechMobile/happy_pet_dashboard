import 'dart:convert';

import 'package:http/http.dart' as http;

class ViaCepService {
  Future<Map<String, dynamic>?> getAddress(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) return null;

    final url = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          return null;
        }
        return data;
      }
    } catch (e) {
      // Handle error or just return null
    }
    return null;
  }
}
