import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notea_frontend/infraestructura/Repositorio/repositorioUsuarioImpl.dart';
import '../../../dominio/agregados/usuario.dart';
import '../../api/remoteDataUsuario.dart';
import 'package:http/http.dart' as http;


part 'usuario_event.dart';
part 'usuario_state.dart';

class UsuarioBloc extends  Bloc<UsuarioEvent, UsuarioState> {

  UsuarioBloc() : super(const UsuarioInitialState()){

   //generamos los comportamientos del bloc

    on<LoginEvent>((event, emit) async { //para que el bloc escuche el evento Login
      print('estoy llamando al evento login');
      emit(const UsuarioLoadingState()); //emitimos el estado de cargando
      
      //realizamos la logica de negocio para el login
      await Future.delayed(const Duration(seconds: 2));
      final repositorio = RepositorioUsuarioImpl(remoteDataSource: RemoteDataUsuarioImp(client: http.Client()));
      final usuario = await repositorio.loginUsuario(event.email, event.password);

      usuario.isLeft() ?  emit(UsuarioSuccessState(usuario: usuario.left!))  //emitimos el estado de exito
        : emit(const UsuarioFailureState()); //emitimos el estado de error
      }
    );
  }
}