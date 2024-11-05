import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:idsoberana_plugin/idsoberana_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _idsoberanaPlugin = IdsoberanaPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _idsoberanaPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    _idsoberanaPlugin.bearerToken = '<AQUI_VA_EL_TOKEN>';

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> eliminarArchivo() async {
    try {
      await _idsoberanaPlugin.eliminarArchivo();
      print('Archivo eliminado exitosamente.');
    } catch (e) {
      print('Error al eliminar el archivo: $e');
    }
  }

  Future<void> iniciar() async {
    try {
      String? qrStr = await _idsoberanaPlugin.obtenerIdentidad( {"documento": "12345678", "tipodoc_id": 1} );
      if(qrStr == IdsoberanaPlugin.IDS_RET_CREARUSR){
        print('crear usuario');
      }
      else if(qrStr == IdsoberanaPlugin.IDS_RET_CONFIGURANDO){
        print('sistema config');
      }
      else {
        print(qrStr);
      }
    } catch (e) {
      print('Error al iniciar: $e');
    }
  }

  Future<void> generarIdsAleatorios() async {
    try {
      await _idsoberanaPlugin.renovarReg();
    } catch (e) {
      print('Error mkRnd: $e');
    }
  }

  Future<void> crearUsuario() async {
    try {
      dynamic res = await _idsoberanaPlugin.crearUsuario(
        documento: '12345678',
        nombres: 'Juan',
        apellidos: 'Pérez',
        mail: 'juan.perez@example.com',
        clave: 'C0ntra\$ena123'
      );
      print(res);
    } catch (e) {
      print('Error crearUsuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: eliminarArchivo,
                child: Text('Eliminar Archivo'),
              ),
              ElevatedButton(
                onPressed: iniciar,
                child: Text('Iniciar'),
              ),
              ElevatedButton(
                onPressed: generarIdsAleatorios,
                child: Text('Gastar Ids aleatoreos'),
              ),
              ElevatedButton(
                onPressed: crearUsuario,
                child: Text('Crear Usuario'),
              ),
            ],
          ),
        )
      ),
    );
  }
}
