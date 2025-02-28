import 'package:amc_2024/injection_container.dart';
import 'package:amc_2024/src/domain/electricity/hydro_model.dart';
import 'package:amc_2024/src/infra/http_client.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class HydroApi {
  final HttpClient httpClient = locator<HttpClient>();

  Future<HydroModel> getHydroData() async {
    final Response response = await httpClient.get(
        'https://www.hydroquebec.com/data/documents-donnees/donnees-ouvertes/json/demande.json',
        '');
    var mappedData = jsonDecode(response.data);

    return HydroModel.fromJson(mappedData);
  }
}
