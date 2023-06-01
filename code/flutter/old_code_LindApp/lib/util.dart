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
import 'package:test/minimize.dart';

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

/// Get String from HTTP request containting obj file
/// param url: url to get from
/// returns Future<String> of obj file
Future<String> getObjHTTP(String url) async {
  final dio = Dio();
  // Note that we use the 'content-Type' header to tell the server what we want
  // this can and should be changed
  dio.options.headers['content-Type'] = 'getObj';
  final response = await dio.get(url);
  return response.data.toString();
}

/// Get String from HTTP request containting mtl file
/// param url: url to get from
/// returns Future<String> of mtl file
Future<String> getMtlHTTP(String url) async {
  final dio = Dio();
  // Note that we use the 'content-Type' header to tell the server what we want
  // this can and should be changed
  dio.options.headers['content-Type'] = 'getMtl';
  final response = await dio.get(url);
  return response.data.toString();
}

/// Get String from HTTP request containting img file
/// param url: url to get from
/// returns Future<String> of img file
Future<String> getImgHTTP(String url) async {
  final dio = Dio();
  // Note that we use the 'content-Type' header to tell the server what we want
  // this can and should be changed
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

/// sends images to server if they are picked from gallery
Future<String> sendImagesUpload(String url, Uint8List img1, Uint8List img2,
    Uint8List img3, String identifier, int nippleDist) async {
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
String getIdentifier() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

/// convert list of Vector3 to list of doubles
List<double> flattenVector3List(List<Vector3> vecs, Globals g) {
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
ml.Vector calculateEigenValues(Object obj, ml.Vector mean, Globals g) {
  List<double> w = flattenVector3List(obj.mesh.init_vertices, g);
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
  List<double> eigVals = g.eigValsVec.toList();
  eigVals[1] = size * g.stddevs[0];
  eigVals[2] = vertLift * g.stddevs[1];
  eigVals[3] = clW * g.stddevs[2];
  g.eigValsVec = ml.Vector.fromList(eigVals);
  ml.Vector vec = (g.eigenVecsMat * g.eigValsVec).toVector() + g.meanVec;

  return vec.toList();
}

/// changes a model according to a vector of coordinates
/// param model: reference to cube model to change
/// param vec: vector of cooridnates
/// param g: reference t globals
void changeModel(Object model, List<double> vec, Globals g) {
  model.mesh.vertices = listToVectors(vec);
  List<Polygon> polys = deepCopyPoly(model.mesh.init_vertexIndices);
  rebuildVertices(
    model.mesh.vertices,
    model.mesh.init_texcoords,
    model.mesh.init_vertexIndices,
    model.mesh.init_TextIndices,
  );
  model.mesh.init_vertexIndices = polys;
}

List<Vector3> listToVectors(List<double> list) {
  List<Vector3> ret = [];
  for (int i = 0; i < list.length; i = i + 3) {
    ret.add(Vector3(list[i], list[i + 1], list[i + 2]));
  }
  return ret;
}

/// is used to load a default model from assets
Future<String> getOBJasString(String ret) async {
  String data = await rootBundle.loadString('objModel.obj');
  List<String> lines = data.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (!lines[i].startsWith('v ')) {
      ret = '$ret${lines[i]}\n';
    }
  }
  return ret;
}

/// this method does the same rebuilding as defined in mesh.dart
/// does inplace rebuilding, so need to deepcopy the lists before
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

/// interpolates the modelvectors, so only the breast area is changed and
/// on the baundary the change is interpolated
List<double> interpolateVectors(List<double> adjustedVec, Globals g) {
  List<double> dists = [];

  for (int i in g.breastIndices) {
    dists.add(getNearestDist(g.outline, adjustedVec, adjustedVec[3 * i],
        adjustedVec[3 * i + 1], adjustedVec[3 * i + 2]));
  }

  List<int> idxs_exp = expandIndices(g.breastIndices);
  List<double> baseVec = deepCopyDoubleList(g.baseVec);

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

/// calculates for each vertex the nearest distance to the outline
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

/// used to get from 3d indices to flattened 1d indices
List<int> expandIndices(List<int> breastIndices) {
  List<int> ret = [];
  for (int i in breastIndices) {
    ret.add(3 * i);
    ret.add(3 * i + 1);
    ret.add(3 * i + 2);
  }
  ret.sort();
  return ret;
}

List<double> deepCopyDoubleList(List<double> list) {
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

/// sets the camera position to the given rotation around the x axis
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

/// sets the camera position to the given rotation around the y axis
void camSetDegreeY(Scene scene, double a, double min, double max) {
  double z = scene.camera.position.z;
  double x = scene.camera.position.x;
  double d = sqrt(z * z + x * x);
  double theta = atan2(z, x) + a;
  if (degrees(theta) < min || degrees(theta) > max) return;
  double newz = d * sin(theta);
  double newx = d * cos(theta);
  scene.camera.position.z = newz;
  scene.camera.position.x = newx;
  double deg = degrees(theta);
}

/// gets 3d coordinate of 2d point on screen uses inverse of transformation and
/// prior knowledge of what the x coordinate should be to recover depth information
/// [x] defines the x coordinate of the point on the screen
Vector3 get3dPointOfUV(Offset point, double cameraPosition, Globals g) {
  Matrix4 inv = convert_mlMatrix_to_Matrix4(
      convertMatrix4_to_mlMatrix(g.transform).inverse());
  double u = (point.dx / (g.screenwidth / 2)) - 1.0;
  double v = -((point.dy / (g.screenheight / 2)) - 1.0);
  Vector4 uv_near = Vector4(u, v, 0, 1);
  Vector4 uv_far = Vector4(u, v, 1, 1);
  uv_far.applyMatrix4(inv);
  uv_near.applyMatrix4(inv);
  uv_far.scale(1 / uv_far.w);
  uv_near.scale(1 / uv_near.w);
  double x = cameraPosition > 0 ? 9.2 : -8.6;
  Vector3 uv_near3 = Vector3(uv_near.x, uv_near.y, uv_near.z);
  Vector3 uv_far3 = Vector3(uv_far.x, uv_far.y, uv_far.z);
  Vector3 dir = uv_near3 - uv_far3;
  double a = (x - uv_near3.x) / dir.x;
  Vector3 p = uv_near3 + dir * a;
  return p;
}

ml.Matrix convertMatrix4_to_mlMatrix(Matrix4 m) {
  ml.Matrix ret = ml.Matrix.fromList([
    [m.row0.x, m.row0.y, m.row0.z, m.row0.w],
    [m.row1.x, m.row1.y, m.row1.z, m.row1.w],
    [m.row2.x, m.row2.y, m.row2.z, m.row2.w],
    [m.row3.x, m.row3.y, m.row3.z, m.row3.w]
  ]);
  return ret;
}

Matrix4 convert_mlMatrix_to_Matrix4(ml.Matrix m) {
  Matrix4 ret = Matrix4.fromList([
    m[0][0],
    m[1][0],
    m[2][0],
    m[3][0],
    m[0][1],
    m[1][1],
    m[2][1],
    m[3][1],
    m[0][2],
    m[1][2],
    m[2][2],
    m[3][2],
    m[0][3],
    m[1][3],
    m[2][3],
    m[3][3]
  ]);
  return ret;
}
