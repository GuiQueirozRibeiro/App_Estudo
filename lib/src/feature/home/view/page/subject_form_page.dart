import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/subject.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../../usecase/firestore_service.dart';
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
  final List<String> classOptions = ['1A', '1B', '2A', '2B', '3A', '3B'];
  bool _isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  List selectedClasses = [];

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthViewModel>(context, listen: false);
    currentUser = authProvider.currentUser;
    nameController.text = widget.subject.name;
    imageUrlController.text = widget.subject.imageUrl;
    selectedClasses = widget.subject.classes.toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool?> _showDialog(String title, String content) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
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

  void _selectImage(String imagePath) {
    setState(() {
      _image = File(imagePath);
    });
  }

  Future<void> _submitForm() async {
    final firestoreProvider =
        Provider.of<FirestoreService>(context, listen: false);
    final confirm = await _showDialog(
      'upload_subject'.i18n(),
      'are_you_sure'.i18n(),
    );
    if (confirm!) {
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
        await firestoreProvider.updateSubject(widget.subject);
      } catch (error) {
        await _showDialog(
          'error_occurred'.i18n(),
          'error_updating_subject'.i18n(),
        );
      } finally {
        Modular.to.pop();
        setState(() => _isLoading = false);
      }
    } else {
      return;
    }
  }

  Widget _buildClassItem(bool isChecked, String classOption) {
    return Expanded(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isChecked) {
                selectedClasses.remove(classOption);
              } else {
                selectedClasses.add(classOption);
              }
            });
          },
          splashColor: Theme.of(context).colorScheme.primary,
          child: Container(
            decoration: BoxDecoration(
              color: isChecked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  classOption,
                  style: TextStyle(
                    color: isChecked
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16.0,
                  ),
                ),
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      if (isChecked) {
                        selectedClasses.remove(classOption);
                      } else {
                        selectedClasses.add(classOption);
                      }
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  CustomTextField(
                    text: 'Name',
                    controller: nameController,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (classOptions.length / 2).ceil(),
                      itemBuilder: (ctx, index) {
                        int firstIndex = index * 2;
                        int secondIndex = firstIndex + 1;

                        return Row(
                          children: [
                            if (firstIndex < classOptions.length)
                              _buildClassItem(
                                selectedClasses
                                    .contains(classOptions[firstIndex]),
                                classOptions[firstIndex],
                              ),
                            if (secondIndex < classOptions.length)
                              _buildClassItem(
                                selectedClasses
                                    .contains(classOptions[secondIndex]),
                                classOptions[secondIndex],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
