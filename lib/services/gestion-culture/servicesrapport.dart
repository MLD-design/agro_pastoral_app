import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/gestion-culture/modelrapport.dart';


class RapportService {

  final String baseUrl = "http://192.168.1.16:3000/api/rapport";

  Future<RapportCulture> getRapport(

      int code_expl, int id_cham, int id_camp) async {

    final res = await http.get(Uri.parse(

        "$baseUrl/$code_expl/$id_cham/$id_camp"));

    if (res.statusCode != 200) {

      throw Exception("Erreur rapport");

    }

    return RapportCulture.fromJson(jsonDecode(res.body));

  }

}