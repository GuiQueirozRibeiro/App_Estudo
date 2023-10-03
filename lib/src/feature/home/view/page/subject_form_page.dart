import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/subject.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../../repository/subject_list.dart';
import '../widget/class_list_view.dart';
import '../widget/subejct_card.dart';

class SubjectFormPage extends StatefulWidget {
  final Subject subject;

  const SubjectFormPage({
    super.key,
    required this.subject,
  });

  @override
  SubjectFormPageState createState() => SubjectFormPageState();
}

class SubjectFormPageState extends State<SubjectFormPage> {
  File? _image;
  late AuthViewModel authProvider;
  late UserModel? currentUser;
  bool _isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  List selectedClasses = [];
  bool _isSnackBarVisible = false;
  final List<SnackBar> _snackBarQueue = [];

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of(context, listen: false);
    currentUser = authProvider.currentUser;
    nameController.text = widget.subject.name;
    imageUrlController.text = widget.subject.imageUrl;
    selectedClasses = widget.subject.classes.toList();
  }

  @override
  void dispose() {
    _snackBarQueue.clear();
    super.dispose();
  }

  Future<bool?> _showErrorDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('error_occurred'.i18n()),
          content: Text('error_updating_subject'.i18n()),
        );
      },
    );
  }

  void _selectImage(String imagePath) {
    setState(() {
      _image = File(imagePath);
    });
  }

  void updateSelectedClasses(bool isChecked, String classOption) {
    setState(() {
      if (isChecked) {
        selectedClasses.remove(classOption);
      } else {
        selectedClasses.add(classOption);
      }
    });
  }

  void _showStatusSnackBar() {
    final snackBar = SnackBar(
      content: Text('no_change'.i18n()),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 2),
    );
    _snackBarQueue.clear();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _snackBarQueue.add(snackBar);
    _showNextSnackBar();
  }

  void _showNextSnackBar() {
    if (!_isSnackBarVisible && _snackBarQueue.isNotEmpty) {
      final snackBar = _snackBarQueue.removeAt(0);

      setState(() {
        _isSnackBarVisible = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
        setState(() {
          _isSnackBarVisible = false;
        });
        _showNextSnackBar();
      });
    }
  }

  Future<void> _submitForm() async {
    final SubjectList subjectProvider = Provider.of(context, listen: false);

    if (_image == null &&
        widget.subject.name == nameController.text &&
        const ListEquality().equals(widget.subject.classes, selectedClasses)) {
      _showStatusSnackBar();
      return;
    }
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.subject.imageUrl;
      if (_image != null) {
        imageUrl = await authProvider.uploadImage(
            _image, widget.subject.id, widget.subject.imageUrl);
      }
      widget.subject.imageUrl = imageUrl ?? '';
      widget.subject.name = nameController.text;
      widget.subject.classes = selectedClasses;
      await subjectProvider.updateSubject(widget.subject);
    } catch (error) {
      await _showErrorDialog();
    } finally {
      Modular.to.pop();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.of(context).size.height * 0.21;

    return Scaffold(
      appBar: AppBar(
        title: Text('subject_form'.i18n()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _submitForm(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SubjectCard(
                    cardHeight: cardHeight,
                    subject: Subject(
                      id: widget.subject.id,
                      name: nameController.text,
                      imageUrl: imageUrlController.text,
                      classes: selectedClasses,
                      teacher: widget.subject.teacher,
                    ),
                    user: UserModel(
                      id: '',
                      name: '',
                      classroom: selectedClasses.join(', '),
                      imageUrl: '',
                      isProfessor: false,
                    ),
                    isForm: true,
                    onImageSelected: _selectImage,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: CustomTextField(
                      text: 'name_field'.i18n(),
                      controller: nameController,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClassListView(
                    selectedClasses: selectedClasses,
                    onClassItemTap: updateSelectedClasses,
                    classOptions: widget.subject.classes,
                  ),
                ],
              ),
            ),
    );
  }
}
