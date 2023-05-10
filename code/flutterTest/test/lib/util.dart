import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:test/flutter_cube.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/globals.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ml_linalg/linalg.dart' as ml;

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

/// debug print for cube
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
Future<String> sendImagesCamera(String url, String img1, String img2,
    String img3, String identifier, int nippleDist) async {
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

Future<String> sendImagesUpload(String url, Uint8List img1, Uint8List img2,
    Uint8List img3, String identifier, int nippleDist) async {
  // need new dio instance for post each request
  final locDio = Dio();
  var data = {
    "img1": img1,
    "img2": img2,
    "img3": img3,
    "nippleDist": nippleDist,
    "identifier": identifier,
  };
  int length = img1.length +
      img2.length +
      img3.length +
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

/// convert list of Vector3 to list of doubles
List<double> vector3sTods(List<Vector3> vecs, Globals g) {
  List<double> doubles = [];
  for (var i = 0; i < vecs.length; i++) {
    doubles.add(vecs[i].x);
    doubles.add(vecs[i].y);
    doubles.add(vecs[i].z);
  }
  return doubles;
}

/// calculates eigenvalues corresponding to PCA
/// saves them in eigVs, sets global values
/// param eigVs: reference to eigenvalues to set
/// param obj: reference to cube object
/// param U_k: first 30 eigenvectors of PCA
/// param mean: mean of all trained models of PCA
/// param g: reference to globals
ml.Vector calcEigVals(Object obj, ml.Matrix U_k, ml.Vector mean, Globals g) {
  List<double> w = vector3sTods(obj.mesh.init_vertices, g);
  ml.Vector wVec = ml.Vector.fromList(w);
  ml.Vector eigVs =
      (g.eigenVecsMat.transpose() * (wVec - g.meanVec)).toVector();
  List<double> eigVsList = eigVs.toList();
  // set base values
  g.baseSize = eigVsList[1] / g.stddevs[0];
  g.size = eigVsList[1] / g.stddevs[0];
  g.baseVertLift = eigVsList[2] / g.stddevs[1];
  g.vertLift = eigVsList[2] / g.stddevs[1];
  g.baseClWidth = eigVsList[3] / g.stddevs[2];
  g.clWidth = eigVsList[3] / g.stddevs[2];

  return eigVs;
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

  List<double> eigVals = g.eigValsVec.toList();
  eigVals[1] = size * g.stddevs[0];
  eigVals[2] = vertLift * g.stddevs[1];
  eigVals[3] = clW * g.stddevs[2];
  g.eigValsVec = ml.Vector.fromList(eigVals);

  debugPrint('[${eigVals[1]}, ${eigVals[2]}, ${eigVals[3]}]');

  ml.Vector mat = (g.eigenVecsMat * g.eigValsVec).toVector() + g.meanVec;

  return mat.toList();
}

/// changes a model according to a vector of coordinates
/// param model: reference to cube model to change
/// param vec: vector of cooridnates
/// param g: reference t globals
void changeModel(Object model, List<double> vec, Globals g) {
  model.mesh.vertices = listToVecs(vec);
  List<Polygon> polys = deepCopyPoly(model.mesh.init_vertexIndices);
  rebuildVertices(
    model.mesh.vertices,
    model.mesh.init_texcoords,
    model.mesh.init_vertexIndices,
    model.mesh.init_TextIndices,
  );
  //scaleModel(model.mesh.vertices, g.scales[0]);
  model.mesh.init_vertexIndices = polys;
}

String shape(List<List<double>> matrix) {
  return "(${matrix.length}, ${matrix[0].length})";
}

bool vecEquals(Vector3 a, Vector3 b) {
  return a.x == b.x && a.y == b.y && a.z == b.z;
}

List<Vector3> listToVecs(List<double> list) {
  List<Vector3> ret = [];
  for (int i = 0; i < list.length; i = i + 3) {
    ret.add(Vector3(list[i], list[i + 1], list[i + 2]));
  }
  return ret;
}

void printDuplicates(List<Vector3> verts, List<int> dups) {
  for (int i = 0; i < dups.length; i = i + 2) {
    debugPrint(
        "${verts[dups[i]]} ${verts[dups[i + 1]]} at ${dups[i]} ${dups[i + 1]}");
  }
}

Future<String> getObjString(String ret) async {
  String data = await rootBundle.loadString('objModel.obj');
  List<String> lines = data.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (!lines[i].startsWith('v ')) {
      ret = '$ret${lines[i]}\n';
    }
  }
  return ret;
}

String vectorToObjString(List<Vector3> vecs) {
  String ret = '';
  for (int i = 0; i < vecs.length; i++) {
    ret = '${ret}v ${vecs[i].x} ${vecs[i].y} ${vecs[i].z}\n';
  }
  return ret;
}

void rebuildVertices(List<Vector3> vertices, List<Offset> texcoords,
    List<Polygon> vertexIndices, List<Polygon> textureIndices) {
  int texcoordsCount = texcoords.length;
  if (texcoordsCount == 0) return;
  List<Vector3> newVertices = <Vector3>[];
  List<Offset> newTexcoords = <Offset>[];
  HashMap<int, int?> indexMap = HashMap<int, int?>();
  for (int i = 0; i < vertexIndices.length; i++) {
    List<int> vi = vertexIndices[i].copyToArray();
    List<int> ti = textureIndices[i].copyToArray();
    List<int> face = List<int>.filled(3, 0);
    for (int j = 0; j < vi.length; j++) {
      int vIndex = vi[j];
      int tIndex = ti[j];
      int vtIndex = vIndex * texcoordsCount + tIndex;
      int? v = indexMap[vtIndex];
      if (v == null) {
        face[j] = newVertices.length;
        indexMap[vtIndex] = face[j];
        newVertices.add(vertices[vIndex].clone());
        newTexcoords.add(texcoords[tIndex]);
      } else {
        face[j] = v;
      }
    }
    vertexIndices[i].copyFromArray(face);
  }
  //thisisit(counter.toString());
  vertices
    ..clear()
    ..addAll(newVertices);

  texcoords
    ..clear()
    ..addAll(newTexcoords);
}

List<Polygon> deepCopyPoly(List<Polygon> polygons) {
  List<Polygon> ret = [];
  for (int i = 0; i < polygons.length; i++) {
    ret.add(polygons[i].clone());
  }
  return ret;
}

List<Vector3> deepCopyVec(List<Vector3> vecs) {
  List<Vector3> ret = [];
  for (int i = 0; i < vecs.length; i++) {
    ret.add(vecs[i].clone());
  }
  return ret;
}

void scaleModel(List<Vector3> vertices, double scale) {
  for (int i = 0; i < vertices.length; i++) {
    vertices[i].scale(scale);
  }
}

List<double> interpolateVectors(List<double> adjustedVec, Globals g) {
  List<double> dists = [];

  for (int i in g.brestIndices) {
    dists.add(getNearestDist(g.outline, adjustedVec, adjustedVec[3 * i],
        adjustedVec[3 * i + 1], adjustedVec[3 * i + 2]));
  }

  List<int> idxs_exp = expandIndices(g.brestIndices);
  List<double> baseVec = copyDoubleList(g.baseVec);

  for (int i = 0; i < idxs_exp.length; i++) {
    double dist = dists[i ~/ 3];
    if (dist > g.distCutoff) {
      baseVec[idxs_exp[i]] = adjustedVec[idxs_exp[i]];
    } else {
      baseVec[idxs_exp[i]] = (dist / g.distCutoff) * adjustedVec[idxs_exp[i]] +
          (1 - (dist / g.distCutoff)) * baseVec[idxs_exp[i]];
    }
  }
  return baseVec;
}

double getNearestDist(
    List<int> outline, List<double> vec, double x, double y, double z) {
  double minDist = 100000;
  for (int vert in outline) {
    double x_base = vec[vert * 3];
    double y_base = vec[vert * 3 + 1];
    double z_base = vec[vert * 3 + 2];
    double dist = sqrt((x - x_base) * (x - x_base) +
        (y - y_base) * (y - y_base) +
        (z - z_base) * (z - z_base));
    if (dist < minDist) {
      minDist = dist;
    }
  }
  assert(minDist < 100000);
  return minDist;
}

List<int> expandIndices(List<int> brestIndices) {
  List<int> ret = [];
  for (int i in brestIndices) {
    ret.add(3 * i);
    ret.add(3 * i + 1);
    ret.add(3 * i + 2);
  }
  ret.sort();
  return ret;
}

List<double> copyDoubleList(List<double> list) {
  List<double> ret = [];
  for (int i = 0; i < list.length; i++) {
    ret.add(list[i]);
  }
  return ret;
}

void setCamPos(Scene scene, Vector3 pos) {
  scene.camera.position.x = pos.x;
  scene.camera.position.y = pos.y;
  scene.camera.position.z = pos.z;
}

void setModelAndCamera(
    Object model, Scene scene, Vector3 rot, Vector3 modPos, Vector3 camPos) {
  model.rotation.x = rot.x;
  model.rotation.y = rot.y;
  model.rotation.z = rot.z;
  model.position.x = modPos.x;
  model.position.y = modPos.y;
  model.position.z = modPos.z;
  setCamPos(scene, camPos);
  scene.update();
  model.updateTransform();
}

void camSetDegreeX(Scene scene, double a, double min, double max) {
  double z = scene.camera.position.z;
  double y = scene.camera.position.y;
  double d = sqrt(z * z + y * y);
  double theta = atan2(y, z) + a;
  if (degrees(theta) < min || degrees(theta) > max) return;
  double newz = d * cos(theta);
  double newy = d * sin(theta);
  scene.camera.position.z = newz;
  scene.camera.position.y = newy;
  double deg = degrees(theta);
}
