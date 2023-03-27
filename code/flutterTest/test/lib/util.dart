import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:test/flutter_cube.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

final dio = Dio();

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

void printHTTP(String url) async {
  final response = await dio.get(url);
  debugPrint(response.data.toString().length.toString());
}

/// Get String from HTTP request containting obj file
/// param url: url to get from
/// returns Future<String> of obj file
Future<String> getObjHTTP(String url) async {
  dio.options.headers['content-Type'] = 'getObj';
  final response = await dio.get(url);
  debugPrint('getObj ' + url);
  return response.data.toString();
}

/// Get String from HTTP request containting mtl file
/// param url: url to get from
/// returns Future<String> of mtl file
Future<String> getMtlHTTP(String url) async {
  dio.options.headers['content-Type'] = 'getMtl';
  final response = await dio.get(url);
  debugPrint('getMtl ' + url);
  debugPrint(response.data.toString());
  return response.data.toString();
}

/// Get String from HTTP request containting img file
/// param url: url to get from
/// returns Future<String> of img file
Future<String> getImgHTTP(String url) async {
  dio.options.headers['content-Type'] = 'getImg';
  final response = await dio.get(url);
  debugPrint('getImg ' + url);
  return response.data.toString();
}

/// sends images to server
/// param url: url to send to
/// param imageUrls: list of image urls (can be local or network)
/// param identifier: identifier for the images
void sendImages(String url, List<String> imageUrls, String identifier) async {
  for (var i = 0; i < imageUrls.length; i++) {
    var str = await postHTTP(url, imageUrls[i], '$identifier-$i');
    debugPrint(str);
  }
}

/// sends one image to server
/// param url: url to send to
/// param imageUrl: image url (can be local or network)
/// param identifier: identifier for the image
/// returns Future<String> of response
Future<String> postHTTP(String url, String imageUrl, String identifier) async {
  Uint8List bytes = await networkImgToBytes(imageUrl);
  dio.options.headers['content-Type'] = identifier;
  var response = await dio.post(
    url,
    data: bytes,
    options: Options(
      headers: {
        Headers.contentLengthHeader: bytes.length,
      },
    ),
  );

  return response.toString();
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
