import 'dart:convert';
import 'dart:io';

import 'package:idsoberana_plugin/sistema/registro.dart';

import 'idsoberana_plugin_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class IdsoberanaPlugin {
  static const String IDS_RET_CREARUSR = "101";
  static const String IDS_RET_CONFIGURANDO = "201";
  final String urlQr = "http://eti.icu/";
  String credenciafile = "idscfg.json";
  String? bearerToken;
  Registro reg = Registro();

  IdsoberanaPlugin(){
    reg.crear();
  }

  Future<String?> getPlatformVersion() {
    return IdsoberanaPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> getTest() {
    return IdsoberanaPluginPlatform.instance.getTest();
  }

  Future<File> obtenerArchivo() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$credenciafile');
    return file;
  }

  Future<bool> eliminarArchivo() async {
    //final directory = await getApplicationDocumentsDirectory();
    //final file = File('${directory.path}/$credenciafile');
    final file = await obtenerArchivo();

    if (await file.exists()) {
      file.delete();
    }

    return true;
  }
  Future<bool> _escribirArchivo(dynamic archivo) async {
    try {
      //final directory = await getApplicationDocumentsDirectory();
      //final file = File('${directory.path}/$credenciafile');
      final file = await obtenerArchivo();

      await file.writeAsString(jsonEncode(archivo), mode: FileMode.write);
      //print('Archivo guardado en: ${file.path}');
      return true;
    } catch (e) {
      //print('Error al escribir el carnet: $e');
      throw Exception( e );
    }
  }

  Future<dynamic> _leerArchivo() async {
    //final directory = await getApplicationDocumentsDirectory();
    //final file = File('${directory.path}/$credenciafile');
    final file = await obtenerArchivo();

    if (await file.exists()) {
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } else {
      throw Exception('El archivo $credenciafile no existe');
    }
  }

  Future<http.Response> _conectar({
    required String url,
    required dynamic parametros,
    String metodo = 'POST',
  }) async {
    final headers = {
      "Content-Type": "application/json",
      if (bearerToken != null) "Authorization": "Bearer $bearerToken"
    };

    http.Response respuesta;
    if (metodo == 'POST') {
      respuesta = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(parametros),
      );
    } else if (metodo == 'GET') {
      String queryString =
          Uri(queryParameters: {for (var param in parametros) ...param}).query;
      String fullUrl = '$url?$queryString';
      respuesta = await http.get(
        Uri.parse(fullUrl),
        headers: headers,
      );
    } else {
      throw Exception("HTTP no soportado");
    }
    return respuesta;
  }

  Future<String> _obtenerURL(dynamic json) async {
    Map<dynamic, dynamic> usr = json;

    //int control = rnd.nextInt(256);
    int control = reg.obtenerId();
    if( control == -1 ){
      print('Se generan nuevamente los ids');
      reg.crear();
      control = reg.obtenerId();
    }
    int enteroUsrId = int.parse(usr['id'].toString());
    int newCtrl = enteroUsrId + control;
    print( "nctrl = {$newCtrl}");
    String ctrlHex = control.toRadixString(16).padLeft(2,'0');
    String idHex = ( newCtrl ).toRadixString(16).padLeft(6,'0');

    await _actualizarUsuarioCfg(usr);

    String defk = "$urlQr?q=$idHex$ctrlHex";
    return defk;
  }

  Future<http.Response> _wsconsume({required String ws, required dynamic params, String method = "POST"}) async {
    try {
      final respuesta = await _conectar(
          url:
          'https://identidadsoberana.evolutool.com/index.php/$ws',
          parametros: params,
          metodo: method);
      return (respuesta);
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Future<http.Response> _srvMiIdentidad(dynamic params) async {
    String endpoint = "UsuarioPorDocumentoYTipo";
    try{
      return await _wsconsume( ws: endpoint, params: params );
    }
    catch(e){
      rethrow;
    }
  }

  Future<dynamic> _idExists(dynamic params) async {
    //final directory = await getApplicationDocumentsDirectory();
    //final file = File('${directory.path}/$credenciafile');
    final file = await obtenerArchivo();
    dynamic res = {'id': 0,'fileexists':false, 'userexists' : false};

    if (await file.exists()) {
      dynamic datos = await _leerArchivo();
      bool sinusr = true;
      datos.forEach((identidad) {
        String l_doc = identidad['documento'].toString();
        String l_tid = identidad['tipodoc_id'].toString();
        String p_doc = params['documento'].toString();
        String p_tid = params['tipodoc_id'].toString();

        if( l_tid == p_tid && l_doc == p_doc ){
          res = {'id':identidad['id'],'fileexists':true, 'userexists' : true};
          reg.cargar( identidad['log'] );
          sinusr = false;
        }
      });
      if( sinusr ) {
        res = {'id': 0, 'fileexists': true, 'userexists': false};
      }
    }

    return res;
  }

  Future<bool> _actualizarUsuarioCfg(dynamic usr) async {
    //final directory = await getApplicationDocumentsDirectory();
    //final file = File('${directory.path}/$credenciafile');
    final file = await obtenerArchivo();
    bool ret = false;

    if(await file.exists()){
      dynamic decodedJson = await _leerArchivo();
      dynamic mod = [];

      decodedJson.forEach((idDt) {
        String tpi = idDt['tipodoc_id'].toString();
        String doc = idDt['documento'].toString();
        String utpi = usr['tipodoc_id'].toString();
        String udoc = usr['documento'].toString();
        if (utpi == tpi && udoc == doc) {
          idDt['log'] = reg.logId;
          ret = true;
        }
        mod.add( idDt );
      });
      await _escribirArchivo(mod);
    }
    else{
      throw 'El archivo $credenciafile no existe';
    }

    return ret;
  }

  Future<bool> _agregarUsuarioCfg( dynamic usr, bool fileexists) async {
    dynamic decodedJson = [];
    if (fileexists) {
      decodedJson = await _leerArchivo();
    }

    bool usrnuevo = true;
    decodedJson.forEach((idDt) {
      String tpi = idDt['tipodoc_id'];
      String doc = idDt['documento'];
      if (usr['tipodoc_id'] == tpi && usr['documento'] == doc) {
        usrnuevo = false;
      }
    });

    if (usrnuevo) {
      usr['log'] = reg.logId;
      decodedJson.add(usr);
      try {
        return await _escribirArchivo(decodedJson);
      }
      catch(e){
        rethrow;
      }
    }
    else {
      return true;
    }
  }

  Future<void> renovarReg () async {
    print(reg.obtenerId());
    dynamic rLIid = reg.logId;
    print(rLIid);
  }

  Future<String?> obtenerIdentidad(dynamic params) async {
    dynamic idUsr = await _idExists(params);
    String codErr = IDS_RET_CONFIGURANDO;

    if (idUsr['id'] == 0) {
      http.Response sMyId;
      try{
        sMyId = await _srvMiIdentidad(params);
      }
      catch(e){
        throw 'Error: $e';
      }

      final datos = jsonDecode( sMyId.body );
      if (datos.isNotEmpty)  {
        datos.forEach((identidad) async {
          try{
            bool addOk = await _agregarUsuarioCfg( identidad , idUsr['fileexists']);
            if(addOk){
              return await _obtenerURL( identidad );
            }
          }catch(e){
            rethrow;
          }

        });
      }
      else{
        codErr = IDS_RET_CREARUSR;
      }
    } else {
      params['id'] = idUsr['id'];
      return await _obtenerURL( params );
    }
    return codErr;
  }

  Future<String?> configurar(dynamic params) async {
    dynamic idUsr = await _idExists(params);
    String? codErr = IDS_RET_CONFIGURANDO;
    if (idUsr['id'] == 0) {
      codErr = await obtenerIdentidad(params);
    }

    return codErr;
  }

  Future<dynamic> crearUsuario({
    String tipodoc_id = "1",
    required String documento,
    int lugarescedulaId = 1,
    required String nombres,
    required String apellidos,
    required String mail,
    String nacimiento = "1900-01-01 00:00:00",
    int generosId = 1,
    int ciudadNacimientoId = 1,
    String grupoSanguineo = "",
    required String clave,
    String foto = "",
    String direccion = "",
    String barrio = "",
    int ciudadResidenciaId = 1,
    String eps = "",
    String ars = "",
}) async {
    String endpoint = "CrearUsuarioDesdeApp";
    Map<dynamic, dynamic> parametros = {
      'tipodoc_id': tipodoc_id,
      'documento': documento.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase(),
      'lugarescedula_id': lugarescedulaId,
      'nombres': nombres,
      'apellidos': apellidos,
      'mail': mail,
      'nacimiento': nacimiento,
      'generos_id': generosId,
      'lugares_id': ciudadNacimientoId,
      'gruposanguineo': grupoSanguineo,
      'clave': clave,
      'foto': foto,
      'direccion': direccion,
      'barrio': barrio,
      'loc_lugares_id': ciudadResidenciaId,
      'eps': eps,
      'ars': ars,
    };

    String jsonString = jsonEncode(parametros);
    String base64String = base64Encode(utf8.encode(jsonString));
    Map<String,dynamic> data = {
      'data' : base64String,
      'errformatjson' : true
    };

    http.Response sMyId;
    try{
      sMyId = await _wsconsume( ws: endpoint, params: data );
    }
    catch(e){
      throw 'Error: $e';
    }

    final datos = jsonDecode( sMyId.body );
    if( datos['cod'] == 200 ){
      dynamic rData = datos['data'];
      parametros['id'] = rData['id'];

      final file = await obtenerArchivo();
      bool addFl = await _agregarUsuarioCfg( parametros , await file.exists());
      if(addFl) {
        return datos;
      }
      else{
        throw ('No fue posible agregar el usuario');
      }
    }
    else{
      return datos;
    }
  }

}
