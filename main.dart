// Importação de pacotes necessarios para o funcionamento da aplicação
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//Api Armazenada em uma constante, garantindo que a url não mude nunca
const request = 'https://api.hgbrasil.com/finance?key=73a3715d';

//chamada do metodo principal passando "async" indicando ser uma função assintrona
//em que a resposta não chega no mesmo tempo
void main() async {
  runApp(MaterialApp(
    title: "Moeda Hoje",
    //chamada de estado Home
    home: Home(),
    //declaração de tema para a aplicação, tema usado em diversas partes do aplicativo
    theme: ThemeData(
        hintColor: Colors.green,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          hintStyle: TextStyle(color: Colors.green),
        )),
  ));
}

//metodo que extrai da api as informações e as convertem de Json para Map
//em outras linguagens chamado de Array
Future<Map> getData() async {
  //a função no futuro espera o retorno de um array ou Map
  //o pacote http cria um objeto response usando a classe Response
  //o objeto armazena os dados da APi e os torna URI
  http.Response response = await http.get(Uri.parse(request));
  //converte o as informações de Json para array, facilitando o acesso e impressão das informações
  //usando a sintaxe []
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

//criação de um estado Home o qual é carragado na classe Home
class _HomeState extends State<Home> {
  //controladores de Label
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

//armazena os valores de moedas
  double dolar;
  double euro;

  void _clearAll() {
    // limpa os labels
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      // tratativa de erros, caso não retorne o valor do label limpe os labels
      _clearAll();
      return;
    }
    //senão  atualize os valores no ato da insersão
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    // tratativa de erros, caso não retorne o valor do label limpe os labels
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    //senão  atualize os valores no ato da insersão

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    // tratativa de erros, caso não retorne o valor do label limpe os labels
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    //senão  atualize os valores no ato da insersão

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    // widget que só permite o carregamento dos dados dentro dele quando tudo for recebido
    // em outras palavras controla as os estados do app, erro, sucesso e ainda tentando
    // tratando possiveis erros
    return Scaffold(
        //facilita a criação de apps com barra superior
        //abaixo configuração da barra
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Moeda Hoje \$"),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            //configuração e comportamento do corpo da aplicação
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.green, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao Carregar Dados :(",
                      style: TextStyle(color: Colors.green, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.green),
                          //chamada de parte do codigo
                          //bem parecido com o insert e request do PHP aqui ajuda a evitar a reestrita de codigo
                          buildTextField(
                              "Reais", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField("Dólares", "US\$", dolarController,
                              _dolarChanged),
                          Divider(),
                          buildTextField(
                              "Euros", "€", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    //codigo escrito apenas uma vez e replicado ao chamar a função buildTextField()
    String label,
    String prefix,
    TextEditingController c,
    Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.green, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
