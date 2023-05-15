import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
//import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:test/util.dart';

import 'globals.dart';

Globals? g;

class UploadPage extends StatefulWidget {
  UploadPage(Globals gl, {super.key}) {
    g = gl;
  }

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late Image pickedImage;
  //late DropzoneViewController controller;

  // variable to hold image to be displayed
  List<int>? _selectedFile;
  List<Uint8List> uploadedImage = [Uint8List(0), Uint8List(0), Uint8List(0)];
  List<bool> isUploaded = [false, false, false];

//method to load image and update `uploadedImage`

  _startFilePicker(int idx) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files![0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        setState(() {
          uploadedImage[idx] = const Base64Decoder()
              .convert(reader.result.toString().split(',').last);
          _selectedFile = uploadedImage[idx];
        });
      });
      reader.readAsDataUrl(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: isUploaded[0]
                            ? Image.memory(
                                uploadedImage[0],
                              )
                            : const Text('No image selected'),
                      ),
                      FloatingActionButton.extended(
                        heroTag: 'btn_pickLeftImage',
                        onPressed: () async {
                          _startFilePicker(0);
                          isUploaded[0] = true;
                        },
                        label: const Text('Pick left Image'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: isUploaded[1]
                            ? Image.memory(
                                uploadedImage[1],
                              )
                            : Container(
                                color: g!.baseColor,
                                child: Stack(
                                  children: [
                                    /*DropzoneView(
                                      onCreated: (controller) =>
                                          this.controller = controller,
                                      onDrop: acceptFile,
                                    ),*/
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.upload_file),
                                        Text('Drop your image here'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      FloatingActionButton.extended(
                        heroTag: 'btn_pickFrontalImage',
                        onPressed: () async {
                          _startFilePicker(1);
                          isUploaded[1] = true;
                        },
                        label: const Text('Pick frontal Image'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: isUploaded[2]
                            ? Image.memory(
                                uploadedImage[2],
                              )
                            : const Text('No image selected'),
                      ),
                      FloatingActionButton.extended(
                        heroTag: 'btn_pickRightImage',
                        onPressed: () async {
                          _startFilePicker(2);
                          isUploaded[2] = true;
                        },
                        label: const Text('Pick right Image'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('What is the distance between your Nipples?',
              textScaleFactor: 2),
          Slider(
            label: 'Distance in cm: ${g!.nippleDistance.round().toString()}',
            value: g!.nippleDistance,
            divisions: 15,
            min: 15,
            max: 30,
            onChanged: (value) {
              setState(() {
                g!.nippleDistance = value;
              });
            },
          ),
          FloatingActionButton.extended(
            backgroundColor: Colors.indigo,
            heroTag: 'btn_SendPics',
            onPressed: () {
              String ident = getIdent();
              int nd = g!.nippleDistance.round();
              debugPrint('Sending Pictures');
              debugPrint('ident: $ident');
              debugPrint('nippleDistance: $nd');
              sendImagesUpload('http://localhost:8080/', uploadedImage[0],
                  uploadedImage[1], uploadedImage[2], ident, nd);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            label: const Text('Send Pictures'),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Future acceptFile(dynamic event) async {
    final name = event.name;
    //String url = await controller.createFileUrl(event);
    debugPrint('Name: $name');
    setState(() async {
      //uploadedImage[1] = await networkImgToBytes(url);
      isUploaded[1] = true;
    });
  }
}
