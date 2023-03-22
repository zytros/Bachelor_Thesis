import 'dart:convert';

import 'package:test/flutter_cube.dart';
import 'dart:io';

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
