import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../repository/subject_list.dart';

class CustomAvatarProfile extends StatefulWidget {
  final void Function(File image)? onImageChanged;
  final UserModel user;

  const CustomAvatarProfile({
    this.onImageChanged,
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  CustomAvatarProfileState createState() => CustomAvatarProfileState();
}

class CustomAvatarProfileState extends State<CustomAvatarProfile> {
  final _placeholder = "lib/assets/images/avatar.png";
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

        widget.onImageChanged!(_image!);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 300,
    );

    if (pickedImage != null) {
      final confirmed = await showConfirmationDialog();

      if (confirmed == true) {
        setState(() {
          _image = File(pickedImage.path);
        });

        widget.onImageChanged!(_image!);
      }
    }
  }

  ImageProvider _getImageProvider() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (widget.user.imageUrl.isNotEmpty) {
      return NetworkImage(widget.user.imageUrl);
    } else {
      return AssetImage(_placeholder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SubjectList subjectList = Provider.of(context, listen: false);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onImageChanged != null) {
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
            }
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: FadeInImage(
                    placeholder: AssetImage(_placeholder),
                    image: _getImageProvider(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (widget.onImageChanged != null)
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
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                widget.user.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.user.isProfessor
                    ? subjectList.subjects.first.name
                    : widget.user.classroom,
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
