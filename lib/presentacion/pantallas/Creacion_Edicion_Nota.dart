// ignore_for_file: must_be_immutable, library_private_types_in_public_api, file_names, avoid_print, unnecessary_null_comparison, avoid_init_to_null

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:notea_frontend/dominio/agregados/grupo.dart';
import 'package:notea_frontend/infraestructura/bloc/nota/nota_bloc.dart';
import 'package:notea_frontend/infraestructura/bloc/usuario/usuario_bloc.dart';
import 'package:notea_frontend/presentacion/pantallas/Container_Editor_Nota.dart';
import 'package:notea_frontend/presentacion/pantallas/home_screen.dart';
import 'package:notea_frontend/presentacion/widgets/Boton_Gru_Eti.dart';
import 'package:notea_frontend/presentacion/widgets/ImageBlock.dart';
import 'package:notea_frontend/presentacion/widgets/TareaBlock.dart';
import 'package:notea_frontend/presentacion/widgets/textF.dart';


class AccionesConNota extends StatefulWidget {
  final String accion;
  final List<Grupo>? grupos;
  final List<dynamic>? etiquetas;

  final String? titulo;
  final List<String>? contenidosTotal;



  const AccionesConNota({Key? key, required this.accion, required this.grupos, this.titulo, this.contenidosTotal, this.etiquetas}) : super(key: key);

  @override
  _AccionesConNotaState createState() => _AccionesConNotaState();
}

class _AccionesConNotaState extends State<AccionesConNota> {
  late TextEditingController _tituloController;
  String receivedData = '';


  late List<dynamic> recivedDataList = [];
  late List<dynamic> recivedDataEitquetas = [];         //ACA HAY QUE SETEAR LAS ETIQUETAS QUE TIENE LA NOTA
  late Grupo? receivedDataGrupo = null;

  bool hayGrupo = false;
  bool hayEtiquetas = false;


  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo ?? '');
    print('---');
    print(widget.grupos);
    print('-----');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  void pop(context) {
    _tituloController.dispose();
    Navigator.pop(context);
  }

  //Traemos de la lista de Text, Image, Tarea ...Block los hijos para tener la informacion que conforma la nota
  void handleDataReceived(String data,  List<dynamic> dataList) {
      receivedData = data;
      recivedDataList = dataList;
  }

  Future<String?> htmlPrint(TextBlockPrueba1 textBlock) async {
    String? html = await textBlock.editorKey.currentState?.getHtml();
    return html;
  }

  Future<void> pintaLista() async {
    print('-------ReciveddataList---------');
    print(recivedDataList.length);
    print('-------ReciveddataList---------');
    for (var element in recivedDataList) {
      if(element is TextBlockPrueba1){
        final textBlock = element;
        print('------------');


        String? html = await textBlock.editorKey.currentState?.getHtml();         //Aca captamos el codigo de la lista
        print(html);

        print('------------');
      }else if(element is ImageBlock) {
        print('-----');
        print('Esto es una IMAGEN');
        print(element.controller.getSelectedImage());//Esto me devuelve el objeto imagen
        NetworkImage networkImage = element.controller.getSelectedImage()!.image as NetworkImage;   //NetworkImage acepta la ruta de la imagen
        String imageUrl = networkImage.url;   //Obtenemos el url de la imagen
        Uint8List? imageBuffer = await downloadImage(imageUrl);     //Se convierte la imagen a buffer
        if (imageBuffer != null) {
          String base64Image = base64Encode(imageBuffer);
          // Aquí tienes la imagen codificada en base64
          print('Imagen codificada en base64: $base64Image');     //Esto es lo que se guarda en la base de datos //https://codebeautify.org/base64-to-image-converter
          print('Se guardo el buffer');
        } else {
          // Ocurrió un error al descargar la imagen
          print('Erro mi pana');
        }
        print(element.controller.getImageName());
        print('-----');
      }else if(element is TareaBlock){
        print('-----');
        print('Esto es una TAREA');
        final tareaBlock = element; // Crea una instancia del widget TextBlock
        print(tareaBlock.controller1.listaTareas);
        for (var element in tareaBlock.controller1.listaTareas) {
          print('--------');
          print(element.description);
          print(element.completed);
          print('--------');
        }
      }
    }
  }
  //Traemos de la lista de etiquetas, las etiquetas que seleccione el usuario
  void handleDataEtiquetas(List<dynamic> dataEiquetas) {
      recivedDataEitquetas = dataEiquetas;

      print('--------Lista de etiquetas-------');
      print(recivedDataEitquetas.length);
      print('---------------------------------');

    if(recivedDataEitquetas.isEmpty){
      hayEtiquetas = false;
    }else{
      hayEtiquetas = true;
    }

    setState(() {
      recivedDataEitquetas = recivedDataEitquetas;
    });

  }
  void printEtiquetas() {
    for (var element in recivedDataEitquetas) {
      print('-----');
      print(element.id);
      print(element.nombre);
      print(element.idUsuario);
      print(element.color);
      print('-----');
    }
  }
  //Traemos de la lista de grupos el grupo seleccionado
  void handleDataGrupo(Grupo dataGrupo) {
    receivedDataGrupo = dataGrupo;
    print('--------Grupo-------');
    print(receivedDataGrupo!.getNombre());
    print('---------------------------------');
    hayGrupo = true;
    setState(() {
      receivedDataGrupo = receivedDataGrupo;
    });
  }

  Future<Uint8List?> downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
  // Evento de regresar
  void _regresar() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  MessagesScreen(usuario: context.read<UsuarioBloc>().state.usuario!) ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<NotaBloc, NotaState>(
    builder: (context, state) {
      if (state is NotasFailureState){
        return widget.titulo!.isEmpty ? const Center(child: Text('Error al crear la nota')) : const Center(child: Text('Error al editar la nota'));
      }
      if(state is NotasCreateSuccessState){

      }
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.accion),
          backgroundColor: const Color(0xFF21579C),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 40),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        hintText: 'Ingrese el título de la nota',
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 500,                                          //Se cambia de tamano al contenedor del contenido de las notas
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ContainerEditorNota(
                          onDataReceived: handleDataReceived,
                          contenidoTotal: widget.contenidosTotal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    children: [
                      Text('Etiquetas seleccionadas: ${recivedDataEitquetas.length}'),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: recivedDataEitquetas.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: tag.color,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              tag.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        children: [
                          const Text('Grupo seleccionado:'),
                          hayGrupo ?
                              Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade800,
                                  child: Text(obtenerPrimerasDosLetrasMayusculas(receivedDataGrupo!.getNombre())),
                                ),
                                label: Text(receivedDataGrupo!.getNombre()),
                              ) :
                              const Text(''),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  AnimatedButton(
                    onDataReceivedGrupo: handleDataGrupo,
                    onDataReceivedEtiqueta: handleDataEtiquetas,
                    grupos: widget.grupos,
                    puedeCrear: hayGrupo && hayEtiquetas ? true : false,
                    etiquetas: recivedDataEitquetas,
                    grupo: receivedDataGrupo,
                    listInfo: recivedDataList,
                    tituloNota:_tituloController.text,
                  ),

                  if (hayEtiquetas && hayGrupo && recivedDataList.isNotEmpty && _tituloController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 40, bottom: 50), // Margen de 16.0 en todos los lados
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            pintaLista();


                            // print(_tituloController.text);
                            // print(recivedDataList.length);
                            // print(receivedDataGrupo!.getNombre());
                            // print(recivedDataEitquetas.length);
                            // BlocProvider.of<NotaBloc>(context).add(
                            //   CreateNotaEvent(
                            //     tituloNota: _tituloController.text,
                            //     listInfo: recivedDataList,
                            //     grupo: receivedDataGrupo,
                            //     etiquetas: recivedDataEitquetas,
                            //   ),
                            // );
                            // _regresar();
                          },
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.sd_storage_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),


                ],
              ),
            ),
          ),
        ),
      );
      }
    );
  }
}


String obtenerPrimerasDosLetrasMayusculas(String texto) {
  if (texto.length >= 2) {
    final primerasDosLetras = texto.substring(0, 2);
    final primerasDosLetrasMayusculas = primerasDosLetras.toUpperCase();
    return primerasDosLetrasMayusculas;
  } else {
    return texto.toUpperCase();
  }
}