import 'dart:io';
import "dart:async";

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

// ignore: must_be_immutable
class ImageInput extends StatefulWidget {
  final Function(String) onSelectImage;
  final bool isProfile;
  File? _image;

  ImageInput(
    this.onSelectImage,
    this._image, {
    this.isProfile = false,
    Key? key,
  }) : super(key: key);

  @override
  ImageInputState createState() => ImageInputState();
}

class ImageInputState extends State<ImageInput> {
  Future<String> saveImage(File image) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage = await image.copy('${appDir.path}/$fileName');
    return savedImage.path;
  }

  _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    ) as XFile;

    final image = File(imageFile.path);
    final imagePath = await saveImage(image);

    setState(() {
      widget._image = image;
    });

    widget.onSelectImage(imagePath);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      final image = File(pickedImage.path);
      final imagePath = await saveImage(image);

      setState(() {
        widget._image = image;
      });

      widget.onSelectImage(imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: Text('take_photo'.i18n()),
                  onPressed: _takePicture,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.photo),
                  label: Text('gallery'.i18n()),
                  onPressed: pickImage,
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  width: widget.isProfile ? 100 : 180,
                  height: widget.isProfile ? 100 : 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    shape:
                        widget.isProfile ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        !widget.isProfile ? BorderRadius.circular(10) : null,
                  ),
                  child: widget.isProfile
                      ? ClipOval(
                          child: widget._image != null
                              ? Image.file(
                                  widget._image!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                  'no_image'.i18n(),
                                  textAlign: TextAlign.center,
                                )),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget._image != null
                              ? Image.file(
                                  widget._image!,
                                  fit: BoxFit.cover,
                                )
                              : Center(child: Text('no_image'.i18n())),
                        ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget._image = null;
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
