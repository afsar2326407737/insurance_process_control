import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:i_p_c/model/jokes_model.dart';

class JokesRepository {
  final int _noofjokes;
  final String _type;
  JokesRepository(this._noofjokes , this._type);
  String get _url =>
      "https://official-joke-api.appspot.com/jokes/random/$_noofjokes";

  String get _typeUrl =>
      "https://official-joke-api.appspot.com/jokes/$_type/ten";

  Future<List<Jokes>> fetchJokes() async {
    final String finalizer = _type == "Any" ? _url : _typeUrl;
    final response = await http.get(Uri.parse(finalizer));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Jokes.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch jokes');
    }
  }

  static Future<List<String>> fetchTypes() async {
    final response = await http.get(
      Uri.parse("https://official-joke-api.appspot.com/types"),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to fetch joke types');
    }
  }
}
