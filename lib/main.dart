import 'package:flutter/material.dart';
import 'package:flutter_sentry/env.dart';
import 'package:sentry/sentry.dart';
import 'dart:async';

// Coloque a DNS do seu projeto do Sentry aqui
final SentryClient _sentry = new SentryClient(dsn: DNS);

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Erro capturado: $error');

  print('Reportando ao Sentry');

  final SentryResponse response = await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Reportado com sucesso! ${response.eventId}');
  } else {
    print('Falha ao reportar ${response.error}');
  }
}

Future<Null> main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

  runZoned<Future<Null>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentry Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _exception() {
    throw Exception('Teste 2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sentry Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Clique no botão abaixo para reportar um erro ao Sentry',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exception,
        child: Icon(Icons.warning),
      ),
    );
  }
}
