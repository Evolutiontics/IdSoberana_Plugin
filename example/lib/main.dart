import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:idsoberana_plugin/idsoberana_plugin.dart';

enum Vigencia { min5, min10, hora1, noExpira }

int vigenciaToMinutes(Vigencia v) {
  switch (v) {
    case Vigencia.min5:
      return 5;
    case Vigencia.min10:
      return 10;
    case Vigencia.hora1:
      return 60;
    case Vigencia.noExpira:
      return 0; // ✅ No expira = 0
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _idsoberanaPlugin = IdsoberanaPlugin();

  static const List<Map<String, String>> _camposDefinidos = [
    {'label': 'Documento',          'id': 'documento'},
    {'label': 'Nombres',            'id': 'nombres'},
    {'label': 'Apellidos',          'id': 'apellidos'},
    {'label': 'Correo electrónico', 'id': 'mail'},
    {'label': 'Fecha nacimiento',   'id': 'nacimiento'},
    {'label': 'Género',             'id': 'generos_id'},
    {'label': 'Tipo de sangre',     'id': 'gruposanguineo'},
    {'label': 'Código',             'id': 'codigo'},
    {'label': 'Foto',               'id': 'foto'},
    {'label': 'Dirección',          'id': 'direccion'},
    {'label': 'EPS',                'id': 'eps'},
    {'label': 'ARL',                'id': 'ars'},
    {'label': 'Tipo usuario',       'id': 'tipousuario_id'},
    {'label': 'Facultad',           'id': 'facultad'},
    {'label': 'Programa',           'id': 'programa'},
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _idsoberanaPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    _idsoberanaPlugin.bearerToken = 'AQUI_VA_EL_TOKEN';

    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> eliminarArchivo() async {
    try {
      await _idsoberanaPlugin.eliminarArchivo();
      debugPrint('Archivo eliminado exitosamente.');
    } catch (e) {
      debugPrint('Error al eliminar el archivo: $e');
    }
  }

  Future<void> iniciar() async {
    try {
      String? qrStr = await _idsoberanaPlugin.obtenerIdentidad({"documento": "12345678", "tipodoc_id": 1});
      if (qrStr == IdsoberanaPlugin.IDS_RET_CREARUSR) {
        debugPrint('crear usuario');
      } else if (qrStr == IdsoberanaPlugin.IDS_RET_CONFIGURANDO) {
        debugPrint('sistema config');
      } else {
        debugPrint(qrStr);
      }
    } catch (e) {
      debugPrint('Error al iniciar: $e');
    }
  }

  Future<void> generarIdsAleatorios() async {
    try {
      await _idsoberanaPlugin.renovarReg();
    } catch (e) {
      debugPrint('Error mkRnd: $e');
    }
  }

  Future<void> crearUsuario() async {
  /*
  Campos posibles:
    documento,
    nombres,
    apellidos,
    mail,
    nacimiento,
    generos_id,
    gruposanguineo,
    codigo,
    foto,
    direccion,
    eps,
    ars,
    tipousuario_id,
    facultad,
    programa,
    clienteid
   */

    try {
      final res = await _idsoberanaPlugin.crearUsuario(
        documento: '12345678002',
        nombres: 'Juan4',
        apellidos: 'Pérez4',
        mail: 'juan.perez4@example.com',
        clave: 'C0ntra\$ena123',
        codigo: '00012345678002',
        clienteid: 'unisabana',
      );
      debugPrint('$res');
    } catch (e) {
      debugPrint('Error crearUsuario: $e');
    }
  }

  Future<Map<String, dynamic>?> _mostrarModalValidez(BuildContext ctx) async {
    final Set<String> seleccion = {'foto', 'codigo', 'nombres', 'apellidos'};
    var vigencia = Vigencia.hora1;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: ctx,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setModal) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 16 + MediaQuery.of(sheetCtx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Configurar visibilidad y vigencia',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Acciones rápidas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setModal(() {
                                      seleccion.addAll(
                                        _camposDefinidos
                                            .map((e) => e['id']!)
                                            .toList(),
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.select_all),
                                  label: const Text('Seleccionar todo'),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setModal(() => seleccion.clear());
                                  },
                                  icon: const Icon(Icons.deselect),
                                  label: const Text('Limpiar'),
                                ),
                              ],
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Campos visibles',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Lista de checkboxes
                            ..._camposDefinidos.map((campo) {
                              final id = campo['id']!;
                              final label = campo['label']!;
                              final isChecked = seleccion.contains(id);
                              return CheckboxListTile(
                                dense: true,
                                controlAffinity:
                                ListTileControlAffinity.leading,
                                value: isChecked,
                                onChanged: (v) {
                                  setModal(() {
                                    if (v == true) {
                                      seleccion.add(id);
                                    } else {
                                      seleccion.remove(id);
                                    }
                                  });
                                },
                                title: Text(label),
                              );
                            }).toList(),
                            const Divider(height: 24),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Vigencia (minutos)',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            RadioListTile<Vigencia>(
                              title: const Text('5 minutos'),
                              value: Vigencia.min5,
                              groupValue: vigencia,
                              onChanged: (v) => setModal(() => vigencia = v!),
                            ),
                            RadioListTile<Vigencia>(
                              title: const Text('10 minutos'),
                              value: Vigencia.min10,
                              groupValue: vigencia,
                              onChanged: (v) => setModal(() => vigencia = v!),
                            ),
                            RadioListTile<Vigencia>(
                              title: const Text('1 hora'),
                              value: Vigencia.hora1,
                              groupValue: vigencia,
                              onChanged: (v) => setModal(() => vigencia = v!),
                            ),
                            RadioListTile<Vigencia>(
                              title: const Text('No expira'),
                              value: Vigencia.noExpira,
                              groupValue: vigencia,
                              onChanged: (v) => setModal(() => vigencia = v!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetCtx, null),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.link),
                            label: const Text('Continuar'),
                            onPressed: () {
                              if (seleccion.isEmpty) {
                                ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Selecciona al menos un campo para continuar.'),
                                  ),
                                );
                                return;
                              }
                              final minutos = vigenciaToMinutes(vigencia);
                              final validez = {
                                'tiempo': minutos, // ✅ No expira => 0
                                'campos': seleccion.toList(),
                              };
                              Navigator.pop(sheetCtx, validez);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> obtenerUrlId({Map<String, dynamic>? validez}) async {
    try {
      final payload = {
        "documento": "1069266350",
        "tipodoc_id": 1,
        if (validez != null) "validez": validez,
      };

      final String? qrStr = await _idsoberanaPlugin.obtenerIdentidad(payload);

      if (qrStr == IdsoberanaPlugin.IDS_RET_CREARUSR) {
        debugPrint('crear usuario');
      } else if (qrStr == IdsoberanaPlugin.IDS_RET_CONFIGURANDO) {
        debugPrint('sistema config');
      } else {
        debugPrint(qrStr);
      }
    } catch (e) {
      debugPrint('Error al iniciar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: eliminarArchivo,
              child: const Text('Eliminar Archivo'),
            ),
            ElevatedButton(
              onPressed: iniciar,
              child: const Text('Iniciar'),
            ),
            ElevatedButton(
              onPressed: generarIdsAleatorios,
              child: const Text('Gastar Ids aleatoreos'),
            ),
            ElevatedButton(
              onPressed: crearUsuario,
              child: const Text('Crear Usuario'),
            ),
            ElevatedButton(
              onPressed: () async {
                await obtenerUrlId();
              },
              child: const Text('Obtener URL sin vigencia'),
            ),
            ElevatedButton(
              onPressed: () async {
                final validez = await _mostrarModalValidez(context);
                if (validez == null) return;
                await obtenerUrlId(validez: validez);
              },
              child: const Text('Obtener URL con vigencia'),
            ),
          ],
        ),
      ),
    );
  }
}