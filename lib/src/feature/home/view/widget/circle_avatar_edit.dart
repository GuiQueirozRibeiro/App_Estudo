import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';

class CircleAvatarWithEditButton extends StatefulWidget {
  final void Function(File image) onImageChanged;
  final String? userImageUrl;

  const CircleAvatarWithEditButton({
    required this.onImageChanged,
    this.userImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  CircleAvatarWithEditButtonState createState() =>
      CircleAvatarWithEditButtonState();
}

class CircleAvatarWithEditButtonState
    extends State<CircleAvatarWithEditButton> {
  File? _image;

  Future<bool?> showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('upload_photo'.i18n()),
          content: Text('are_you_sure'.i18n()),
          actions: [
            TextButton(
              child: Text('no'.i18n()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('yes'.i18n()),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (imageFile != null) {
      final confirmed = await showConfirmationDialog();

      if (confirmed == true) {
        setState(() {
          _image = File(imageFile.path);
        });

        widget.onImageChanged(_image!);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      final confirmed = await showConfirmationDialog();

      if (confirmed == true) {
        setState(() {
          _image = File(pickedImage.path);
        });

        widget.onImageChanged(_image!);
      }
    }
  }

  ImageProvider _getImageProvider() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (widget.userImageUrl != null) {
      return NetworkImage(widget.userImageUrl!);
    } else {
      return const AssetImage("lib/assets/images/avatar.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('take_photo'.i18n()),
                  onTap: () {
                    Navigator.pop(context);
                    _takePicture();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: Text('gallery'.i18n()),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: SizedBox(
                width: 100,
                height: 100,
                child: FadeInImage(
                  placeholder: const AssetImage("lib/assets/images/avatar.png"),
                  image: _getImageProvider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
