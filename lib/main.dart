import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'coin_data.dart' as coinData;
import 'info_prop.dart';

//Variáveis globais
String currentCurrency = '';
double currentCurrencyValue = 0;
bool systemIsIOS = false;
double curPri = 1, priChang24h = 0, priChange24hPerc = 0;
List<InfoProp> listOfInfoProps = [];
String pickerInitialValue = coinData.coinList[0];

Color mainColor = Colors.teal;
Color highlightColor = Colors.white;
Color columnCardColor = Colors.teal[600];
Color bckgColor = Colors.teal[100];

void main() {
  coinData.getCoinData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bitcoin App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  __HomePageState createState() => __HomePageState();
}

class __HomePageState extends State<_HomePage> {
  //Declaração de widgets que serão usados:
  Future<void> attValues(value) async {
    await coinData.getCoinData();
    coinData.makeNumberDataAvailable();
    pickerInitialValue = value.toString();
    curPri = coinData.getCurrentPrice();
    priChang24h = coinData.getPriceChange24hInCurrency();
    priChange24hPerc = coinData.getPriceChangePercentage24hInCurrency();
    currentCurrencyValue = curPri;
    currentCurrency = pickerInitialValue.toUpperCase();
  }

  //Para o material picker:
  List<DropdownMenuItem> getPickerItems() {
    List<DropdownMenuItem<String>> listItems = [];
    for (int i = 0; i < coinData.coinList.length; i++) {
      String currencySymbol = coinData.coinList[i];
      listItems.add(
        new DropdownMenuItem(
            child: Text(currencySymbol.toUpperCase()), value: currencySymbol),
      );
    }
    return listItems;
  }

  DropdownButton<String> myMaterialPicker() {
    return DropdownButton<String>(
      value: pickerInitialValue,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 4,
      dropdownColor: highlightColor,
      items: getPickerItems(),
      hint: Text("Pick your favorite currency"),
      onChanged: (value) async {
        //Tells the coinData the currency we want
        coinData.setCurrency(
            coinData.coinList.indexOf(value.toString().toLowerCase()));
        //Gets the data
        await coinData.getCoinData();
        //Make the data available
        if (coinData.wasResponseSuccessful) {
          coinData.makeNumberDataAvailable();
        }
        //Then update the interface
        if (coinData.wasResponseSuccessful) {
          setState(() {
            pickerInitialValue = value.toString();
            listOfInfoProps = coinData.listOfInfoProps;
            curPri = coinData.getCurrentPrice();
            priChang24h = coinData.getPriceChange24hInCurrency();
            priChange24hPerc = coinData.getPriceChangePercentage24hInCurrency();
            currentCurrencyValue = curPri;
            currentCurrency = pickerInitialValue.toUpperCase();
          });
        }
      },
      style: TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: mainColor,
      ),
    );
  }

  //Para a exibição dos dados de oscilação de preço:
  Widget miniColumn(
      String atext, double avalue, bool aisPercent, bool ahideSignal) {
    String text;
    double value;
    bool isPercent, hideSignal;
    String textOfTheNumber, numberToShow, sinal;

    Color cardBckgColor;
    Color itGotWorseColor = Colors.red[300];
    Color txtColor;

    //Declarando
    text = atext;
    value = avalue;
    isPercent = aisPercent;
    hideSignal = ahideSignal;

    //Retornando a miniColumn
    //Formatting the text
    if (value >= 0) {
      hideSignal ? sinal = '' : sinal = '+';
      cardBckgColor = columnCardColor;
      txtColor = Colors.teal[900];
    } else {
      sinal = ''; //o menos já vem da internet!
      cardBckgColor = itGotWorseColor;
      txtColor = Colors.red[900];
    }
    if (value.abs() < 10) {
      numberToShow = value.toStringAsFixed(3);
    } else if (value.abs() < 100) {
      numberToShow = value.toStringAsFixed(1);
    } else {
      numberToShow = value.toStringAsExponential(1);
    }
    if (isPercent) {
      textOfTheNumber = '$sinal$numberToShow%';
    } else {
      textOfTheNumber = '$sinal$numberToShow ';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardBckgColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: txtColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          DefaultSpaceContainer(),
          Text(
            textOfTheNumber,
            style: TextStyle(
                color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget priceChangCharts() {
    listOfInfoProps = coinData.listOfInfoProps;
    List<Widget> listOfWidgets = [];

    final String currentPriceString = 'Current Price',
        princeChange24hString = 'Price Change 24h',
        princeChangePercent24hString = 'Price Change 24h, %';

    for (final newProp in listOfInfoProps) {
      bool hideSignal = false;
      if (newProp.propName == 'current_price') {
        hideSignal = true;
      }
      listOfWidgets.add(miniColumn(newProp.propName.replaceAll('_', ' '),
          newProp.propValue, newProp.isPercentage, hideSignal));
      listOfWidgets.add(DefaultSpaceContainer());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            miniColumn(currentPriceString, curPri, false, true),
//            DefaultSpaceContainer(),
//            miniColumn(princeChange24hString, priChang24h, false, false),
//            DefaultSpaceContainer(),
//            miniColumn(
//                princeChangePercent24hString, priChange24hPerc, true, false),
//          ],
          children: listOfWidgets,
        ),
      ),
    );
  }

  Container bottomWidget() {
    return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
//          color: highlightColor,
            ),
        alignment: Alignment.center,
        child: systemIsIOS ? MyCupertinoPicker() : myMaterialPicker());
  }

  Widget showExchangeWidget() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Text(
          '1 Bitcoin = ${currentCurrencyValue.toStringAsFixed(2)}\$ @$currentCurrency ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    () async {
      await attValues(pickerInitialValue);
    };
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bitcoin App'),
      ),
      body: Container(
        color: bckgColor,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding:
                            const EdgeInsets.only(top: 20, right: 20, left: 20),
                        child: showExchangeWidget()),
                    Expanded(child: priceChangCharts()),
                  ],
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    child: bottomWidget(),
                    padding: EdgeInsets.only(bottom: 20),
                    color: highlightColor,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class DefaultSpaceContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
    );
  }
}

//todo criar o cupertino pickerrrrr
class MyCupertinoPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
