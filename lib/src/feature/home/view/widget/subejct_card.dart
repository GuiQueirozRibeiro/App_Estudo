import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';

import '../../../auth/repository/user_model.dart';
import '../../repository/subject.dart';

class SubjectCard extends StatefulWidget {
  final double cardHeight;
  final Subject subject;
  final UserModel user;
  final bool isForm;
  final Function(String)? onImageSelected;

  const SubjectCard({
    super.key,
    required this.cardHeight,
    required this.subject,
    required this.user,
    this.isForm = false,
    this.onImageSelected,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  File? _image;

  Future<void> _openImageSelection() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      widget.onImageSelected!(pickedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.isForm
          ? _openImageSelection()
          : Modular.to.pushNamed('subjectDetails/', arguments: widget.subject),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: SizedBox(
          height: widget.cardHeight,
          child: widget.subject.imageUrl == ''
              ? Center(
                  child: Text(
                    'no_image'.i18n(),
                    textAlign: TextAlign.center,
                  ),
                )
              : Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.network(
                                widget.subject.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        widget.subject.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    if (widget.user.isProfessor)
                      Positioned(
                        top: 25,
                        right: 25,
                        child: GestureDetector(
                          onTap: () => Modular.to.pushNamed('subjectFormPage',
                              arguments: widget.subject),
                          child: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    if (!widget.user.isProfessor)
                      Positioned(
                        top: 50,
                        left: 20,
                        child: Text(
                          widget.user.classroom,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        widget.subject.teacher,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
