import 'package:notea_frontend/dominio/agregados/etiqueta.dart';
import 'package:notea_frontend/dominio/agregados/grupo.dart';
import '../../utils/Either.dart';
import '../agregados/nota.dart';

abstract class INotaRepository {
  Future<Either<List<Nota>, Exception>> buscarNotas();
  Future<Either<int, Exception>?> crearNota(String titulo, Map<String, dynamic> listInfoContenido, List<String> etiquetas, Grupo grupo, double? latitud, double? longitud);
  Future<Either<int, Exception>> modificarEstadoNota(String id, String estado);
  Future<Either<int, Exception>> borrarNota(String id);
  Future<Either<List<Nota>, Exception>> buscarNotasGrupos(
      List<Grupo> grupos);
  Future<Either<int, Exception>?> editarNota(String? idNota, String titulo, Map<String, dynamic> listInfoContenido, List<dynamic> etiquetas, Grupo grupo);

}
