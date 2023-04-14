import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scidart/numdart.dart';
import 'package:test/flutter_cube.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/globals.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scidart/scidart.dart';

/// Interpolates vertices between two obj files and updates destination transform
void interpolateObj(Object? lower, Object? upper, Object? dest, double a) {
  assert(lower!.mesh.vertices.length == upper!.mesh.vertices.length);
  int length = lower!.mesh.vertices.length;
  for (int i = 0; i < length; i++) {
    dest!.mesh.vertices[i].x =
        (1 - a) * lower.mesh.vertices[i].x + a * upper!.mesh.vertices[i].x;
    dest.mesh.vertices[i].y =
        (1 - a) * lower.mesh.vertices[i].y + a * upper.mesh.vertices[i].y;
    dest.mesh.vertices[i].z =
        (1 - a) * lower.mesh.vertices[i].z + a * upper.mesh.vertices[i].z;
  }
  dest!.updateTransform();
}

/// Sets position of an object from a vector3
void setPosition(Object? obj, Vector3 pos) {
  obj!.position.x = pos.x;
  obj.position.y = pos.y;
  obj.position.z = pos.z;
}

/// Sets rotation of an object from a vector3
void setRotation(Object? obj, Vector3 rot) {
  obj!.rotation.x = rot.x;
  obj.rotation.y = rot.y;
  obj.rotation.z = rot.z;
}

/// Sets scale of an object from a vector3
void setScale(Object? obj, Vector3 scale) {
  obj!.scale.x = scale.x;
  obj.scale.y = scale.y;
  obj.scale.z = scale.z;
}

/// Sets scale of an object in all dimensions from a double
void setScaleUniform(Object? obj, double scale) {
  setScale(obj, Vector3(scale, scale, scale));
}

/// Read File as String, given filename
/// Does not work on web
String readFile(String filename) {
  return File(filename).readAsStringSync();
}

/// Split lines of read file, given file as string
List<String> splitLines(String text) {
  LineSplitter ls = const LineSplitter();
  return ls.convert(text);
}

/// Add usemtl line
List<String> add_usemtl_line(List<String> lines) {
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('f')) {
      lines.insert(i, 'usemtl myMaterial');
      lines.insert(i, '# need to add this line, so it works with cube');
      break;
    }
  }

  return lines;
}

/// Saves lines in file
/// Does not work on web
void saveLines(List<String> lines, String filename) {
  String fileAsStr = '';
  for (var i = 0; i < lines.length; i++) {
    fileAsStr = '$fileAsStr${lines[i]}\n';
  }
  File(filename).writeAsStringSync(fileAsStr);
}

void thisisit(String a) {
  debugPrint(a);
}

/// Get String from HTTP request containting obj file
/// param url: url to get from
/// returns Future<String> of obj file
Future<String> getObjHTTP(String url) async {
  final dio = Dio();
  dio.options.headers['content-Type'] = 'getObj';
  final response = await dio.get(url);
  return response.data.toString();
}

/// Get String from HTTP request containting mtl file
/// param url: url to get from
/// returns Future<String> of mtl file
Future<String> getMtlHTTP(String url) async {
  final dio = Dio();
  dio.options.headers['content-Type'] = 'getMtl';
  final response = await dio.get(url);
  return response.data.toString();
}

/// Get String from HTTP request containting img file
/// param url: url to get from
/// returns Future<String> of img file
Future<String> getImgHTTP(String url) async {
  final dio = Dio();
  dio.options.headers['content-Type'] = 'getImg';
  final response = await dio.get(url);
  final codec =
      await instantiateImageCodec(stringToUint8List(response.data.toString()));
  final frameInfo = await codec.getNextFrame();
  //g.image = frameInfo.image;
  return response.data.toString();
}

/// sends images to server
/// param url: url to send to
/// params img1, img2, img3: image urls (can be local or network)
/// param identifier: identifier for the images
/// param nippleDist: nipple distance
/// returns Future<String> of response
Future<String> sendImages(String url, String img1, String img2, String img3,
    String identifier, int nippleDist) async {
  // need new dio instance for post each request
  final locDio = Dio();
  Uint8List bytes1 = await networkImgToBytes(img1);
  Uint8List bytes2 = await networkImgToBytes(img2);
  Uint8List bytes3 = await networkImgToBytes(img3);
  var data = {
    "img1": bytes1,
    "img2": bytes2,
    "img3": bytes3,
    "nippleDist": nippleDist,
    "identifier": identifier,
  };
  int length = bytes1.length +
      bytes2.length +
      bytes3.length +
      nippleDist.toString().length +
      identifier.length;
  var response = await locDio.post(
    url,
    data: data,
    options: Options(
      headers: {
        Headers.contentLengthHeader: length,
      },
    ),
  );

  return response.data.toString();
}

/// Convert a network image to a Uint8List
/// param url: url of image (can be local or network)
/// returns Future<Uint8List> of image
Future<Uint8List> networkImgToBytes(String url) async {
  var base64 = await networkImageToBase64(url);
  var bytes = base64ToUnit8list(base64);
  return bytes;
}

/// Convert a network image to a base64 string
/// param url: url of image (can be local or network)
/// returns Future<String> of image
Future<String> networkImageToBase64(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  return base64.encode(response.bodyBytes);
}

/// Convert a base64 string to a Uint8List
/// param base64String: base64 string
/// returns Uint8List of image
Uint8List base64ToUnit8list(String base64String) {
  return base64Decode(base64String);
}

/// Convert a string to a Uint8List
/// Dart strings are UTF-16 encoded, so we need to convert to Latin-1
/// param str: string to convert
/// returns Uint8List of string
Uint8List stringToUint8List(String str) {
  Base64Codec latin1Codec = const Base64Codec();
  var encoded = latin1Codec.decode(str);
  Uint8List bytes = Uint8List.fromList(encoded);
  return bytes;
}

/// get unique identifier
/// returns String of identifier
String getIdent() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

/// change texture
///

// TODO: changes all texures, not just one
// ???????????????????????
void changeTexture(Object obj, Image img) async {
  obj.mesh.texture = img;
}

/// convert list of Vector3 to list of doubles
List<double> vector3sTods(List<Vector3> vecs) {
  List<double> doubles = [];
  for (var i = 0; i < vecs.length; i++) {
    doubles.add(vecs[i].x);
    doubles.add(vecs[i].y);
    doubles.add(vecs[i].z);
  }
  return doubles;
}

/// old code
void adjustModel(
    Object model, double size, double vertLift, double clWidth) async {
  //Array2d mod = matrixDot(eigenVectors, matrixTranspose(arrayToColumnMatrix(mean)));
}

/// calculates eigenvalues corresponding to PCA
/// saves them in eigVs, sets global values
/// param eigVs: reference to eigenvalues to set
/// param obj: reference to cube object
/// param U_k: first 30 eigenvectors of PCA
/// param mean: mean of all trained models of PCA
/// param g: reference to globals
void calcEigVals(List<double> eigVs, Object obj, List<List<double>> U_k,
    List<double> mean, Globals g) {
  //x_red = np.dot(U_k.T, (w - mean).T).real
  List<double> w = vector3sTods(obj.mesh.vertices);
  eigVs.clear();
  for (int i = 0; i < U_k[0].length; i++) {
    double acc = 0;
    for (int j = 0; j < mean.length; j++) {
      acc += U_k[j][i] * w[j] - mean[j];
    }
    eigVs.add(acc);
  }
  // set base values
  g.baseSize = eigVs[1];
  g.size = g.eigVals[1];
  g.baseVertLift = eigVs[2];
  g.vertLift = eigVs[2];
  g.baseClWidth = eigVs[3];
  g.clWidth = eigVs[3];
}

/// creates the updated vector according to PCA
/// param size: size parameter, between -3 and 3, gets multiplied with standarddeviation
/// param clW: cleavage widtg parameter, between -3 and 3, gets multiplied with standarddeviation
/// param vertLift: vertical lift parameter, between -3 and 3, gets multiplied with standarddeviation
/// param g: reference to globals
/// returns: List/Vector corresponding to the new model
List<double> createModelVector(
    double size, double clW, double vertLift, Globals g) {
  //redModel = (np.dot(U_k, x_red) + mean).real
  //               10000*30 30*1

  List<double> prex_red = [g.eigVals[1], g.eigVals[2], g.eigVals[3]];
  g.eigVals[1] = size * g.stddevs[0];
  g.eigVals[2] = vertLift * g.stddevs[1];
  g.eigVals[3] = clW * g.stddevs[2];

  List<double> ret = [];
  for (int i = 0; i < g.eigenVecs.length; i++) {
    double acc = 0;
    for (int j = 0; j < g.eigenVecs[i].length; j++) {
      acc += g.eigenVecs[i][j] * g.eigVals[j];
    }
    ret.add(acc);
  }
  g.eigVals[1] = prex_red[0];
  g.eigVals[2] = prex_red[1];
  g.eigVals[3] = prex_red[2];

  return ret;
}

/// changes a model according to a vector of coordinates
/// param model: reference to cube model to change
/// param vec: vector of cooridnates
/// param g: reference t globals
void changeModel(Object model, List<double> vec, Globals g) {
  int j = 0;
  debugPrint("model length: ${model.mesh.vertices.length}");
  debugPrint(model.mesh.vertices[0].toString());
  debugPrint(model.mesh.vertices[1].toString());
  debugPrint(model.mesh.vertices[2].toString());
  for (int i = 0; i < 3354; i++) {
    model.mesh.vertices[i].x = vec[j];
    model.mesh.vertices[i].y = vec[j + 1];
    model.mesh.vertices[i].z = vec[j + 2];
    j = j + 3;
  }
}
