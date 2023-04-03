import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/util.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'dart:ui';

class Material {
  Material()
      : name = '',
        ambient = Vector3.all(0.1),
        diffuse = Vector3.all(0.8),
        specular = Vector3.all(0.5),
        ke = Vector3.zero(),
        tf = Vector3.zero(),
        mapKa = '',
        mapKd = '',
        mapKe = '',
        shininess = 0,
        ni = 0,
        opacity = 1.0,
        illum = 0;
  String name;
  Vector3 ambient;
  Vector3 diffuse;
  Vector3 specular;
  Vector3 ke;
  Vector3 tf;
  double shininess;
  double ni;
  double opacity;
  int illum;
  String mapKa;
  String mapKd;
  String mapKe;
}

/// Loading material from Material Library File (.mtl).
/// Reference：http://paulbourke.net/dataformats/mtl/
///

// TODO: Implement server mtl file loading.

Future<Map<String, Material>> loadMtl(String fileName,
    {String src = 'a'}) async {
  final materials = Map<String, Material>();
  String data = '';

// try catch if mtl file not found
  try {
    switch (src) {
      case 'a':
        data = await rootBundle.loadString(fileName);
        break;
      case 'f':
        data = await File(fileName).readAsString();
        break;
      case 's':
        data = await getMtlHTTP(fileName);

        // DEBUG
        //data = await rootBundle.loadString('assets/models/fitModel_Demo_Augmentation.mtl');
        break;
      default:
        assert(false, 'Invalid src: $src');
    }
  } catch (_) {
    return materials;
  }

  final List<String> lines = data.split('\n');

  Material material = Material();
  for (String line in lines) {
    List<String> parts = line.trim().split(RegExp(r"\s+"));
    switch (parts[0]) {
      case 'newmtl':
        material = Material();
        if (parts.length >= 2) {
          material.name = parts[1];
          materials[material.name] = material;
        }
        break;
      case 'Ka':
        if (parts.length >= 4) {
          final v = Vector3(double.parse(parts[1]), double.parse(parts[2]),
              double.parse(parts[3]));
          material.ambient = v;
        }
        break;
      case 'Kd':
        if (parts.length >= 4) {
          final v = Vector3(double.parse(parts[1]), double.parse(parts[2]),
              double.parse(parts[3]));
          material.diffuse = v;
        }
        break;
      case 'Ks':
        if (parts.length >= 4) {
          final v = Vector3(double.parse(parts[1]), double.parse(parts[2]),
              double.parse(parts[3]));
          material.specular = v;
        }
        break;
      case 'Ke':
        if (parts.length >= 4) {
          final v = Vector3(double.parse(parts[1]), double.parse(parts[2]),
              double.parse(parts[3]));
          material.ke = v;
        }
        break;
      case 'map_Ka':
        if (parts.length >= 2) {
          material.mapKa = parts.last;
        }
        break;
      case 'map_Kd':
        if (parts.length >= 2) {
          material.mapKd = parts.last;
        }
        break;
      case 'Ns':
        if (parts.length >= 2) {
          material.shininess = double.parse(parts[1]);
        }
        break;
      case 'Ni':
        if (parts.length >= 2) {
          material.ni = double.parse(parts[1]);
        }
        break;
      case 'd':
        if (parts.length >= 2) {
          material.opacity = double.parse(parts[1]);
        }
        break;
      case 'illum':
        if (parts.length >= 2) {
          material.illum = int.parse(parts[1]);
        }
        break;
      default:
    }
  }
  return materials;
}

/// load an image from asset

// Todo: Implement server image loading.

Future<Image> loadImageFromAsset(String fileName, {String src = 'a'}) {
  final c = Completer<Image>();
  var dataFuture;
  switch (src) {
    case 'a':
      dataFuture =
          rootBundle.load(fileName).then((data) => data.buffer.asUint8List());
      break;
    case 'f':
      dataFuture = File(fileName).readAsBytes();
      break;
    case 's':
      dataFuture =
          getImgHTTP(fileName).then((value) => stringToUint8List(value));
      //dataFuture = rootBundle.load('models/texture_Demo_Augmentation.png').then((data) => data.buffer.asUint8List());

      break;
    default:
      assert(false, 'not implemented');
  }

  dataFuture.then((data) {
    instantiateImageCodec(data).then((codec) {
      codec.getNextFrame().then((frameInfo) {
        c.complete(frameInfo.image);
      });
    });
  }).catchError((error) {
    c.completeError(error);
  });
  return c.future;
}

/// load texture from asset
Future<MapEntry<String, Image>?> loadTexture(
    Material? material, String basePath,
    {String src = 'a'}) async {
  // get the texture file name
  if (material == null) return null;
  String fileName = material.mapKa;
  if (fileName == '') fileName = material.mapKd;
  if (fileName == '') return null;

  // try to load image from asset in subdirectories
  Image? image;
  final List<String> dirList = fileName.split(RegExp(r'[/\\]+'));
  while (dirList.length > 0) {
    fileName = path.join(basePath, path.joinAll(dirList));
    try {
      image = await loadImageFromAsset(fileName, src: src);
    } catch (_) {}
    if (image != null) return MapEntry(fileName, image);
    dirList.removeAt(0);
  }
  return null;
}

Future<Uint32List> getImagePixels(Image image) async {
  final c = Completer<Uint32List>();
  image.toByteData(format: ImageByteFormat.rawRgba).then((data) {
    c.complete(data!.buffer.asUint32List());
  }).catchError((error) {
    c.completeError(error);
  });

  return c.future;
}

/// Convert Vector3 to Color
Color toColor(Vector3 v, [double opacity = 1.0]) {
  return Color.fromRGBO(
      (v.r * 255).toInt(), (v.g * 255).toInt(), (v.b * 255).toInt(), opacity);
}

/// Convert Color to Vector3
Vector3 fromColor(Color color) {
  return Vector3(color.red / 255, color.green / 255, color.blue / 255);
}
