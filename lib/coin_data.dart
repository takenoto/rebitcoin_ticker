import 'package:http/http.dart' as http;
import 'dart:convert';

import 'info_prop.dart';

double currentPrice,
    priceChange24hInCurrency,
    priceChangePercentage24hInCurrency;

http.Response response;

var data;

List<InfoProp> listOfInfoProps = [];

//Lista de possíveis moedas
List<String> coinList = [
  'btc',
  'usd',
  'brl',
  'cad',
  'eos',
  'eth',
  'hkd',
  'idr',
  'jpy',
  'krw',
  'kwd',
  'vef',
  'xau',
  'zar'
];

String selectedCurrency = '';

final String url = 'https://api.coingecko.com/api/v3/coins/bitcoin';

bool wasResponseSuccessful = false;

Future<void> getCoinData() async {
  response = null;
  //Não seria necessário toda vez abrir o site, mas vou fazer isso como aprendizado p/ await/async
  try {
    response = await http.get('$url');
  } catch (e) {
    print(e.toString());
  }

  if (response.statusCode == 200) {
    //Concluído com sucesso
    wasResponseSuccessful = true;
    data = response.body;
  } else {
    //Deu algum erro
    wasResponseSuccessful = false;
    print(response.statusCode);
  }
}

void makeNumberDataAvailable() {
  //Making the list empty again
  listOfInfoProps = [];

  currentPrice = double.parse(jsonDecode(data)['market_data']['current_price']
          [selectedCurrency]
      .toString());
  priceChange24hInCurrency = double.parse(jsonDecode(data)['market_data']
          ['price_change_24h_in_currency'][selectedCurrency]
      .toString());
  priceChangePercentage24hInCurrency = double.parse(
      jsonDecode(data)['market_data']['price_change_percentage_24h_in_currency']
              [selectedCurrency]
          .toString());

  //Gera a lista de propriedades
  //todo checa se consegue obter os nomes primeiramente
  //print(jsonDecode(data)['market_data'].toString());
  //print(data['a']);
  var decoded = jsonDecode(response.body) as Map;
  print('decoded: ${decoded['market_data'].keys}');

  for (final name in decoded['market_data'].keys) {
    try {
      final value = decoded['market_data']['$name']['$selectedCurrency'];
      final double newDouble = value;
      //Tenta colocar os valores, mas só se for possível passar como doubles!
      //print('-----------------DEU CERTO----------_???');
      //print('$name = $value');
      //final double newDouble = double.parse(value);
      listOfInfoProps.add(InfoProp(name, newDouble));
    } catch (e) {
      //print(e.toString());
    }
  }
}

void setCurrency(int i) {
  selectedCurrency = coinList[i];
}

double getCurrentPrice() {
  if (data == null) {
    return -999.0;
  }

  return currentPrice;
}

double getPriceChange24hInCurrency() {
  return priceChange24hInCurrency;
}

double getPriceChangePercentage24hInCurrency() {
  return priceChangePercentage24hInCurrency;
}
