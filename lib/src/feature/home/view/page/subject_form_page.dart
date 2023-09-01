import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/subject.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../../viewmodel/subject_form_view_model.dart';
import '../widget/subejct_card.dart';

class SubjectFormPage extends StatefulWidget {
  final Subject? subject;
  final SubjectFormViewModel viewModel = SubjectFormViewModel();

  SubjectFormPage({
    super.key,
    this.subject,
  }) {
    if (subject != null) {
      viewModel.nameController.text = subject!.name;
      viewModel.imageUrlController.text = subject!.imageUrl;
      viewModel.selectedClasses = subject!.classes.toList();
    }
  }

  @override
  SubjectFormPageState createState() => SubjectFormPageState();
}

class SubjectFormPageState extends State<SubjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> classOptions = ['1A', '1B', '2A', '2B', '3A', '3B'];
  late UserModel? currentUser;
  final StreamController<String> _nameStreamController =
      StreamController<String>();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    currentUser = authProvider.currentUser;
    widget.viewModel.nameController.addListener(() {
      _nameStreamController.add(widget.viewModel.nameController.text);
    });
  }

  @override
  void dispose() {
    _nameStreamController.close();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final isValid = Form.of(context).validate();

    if (!isValid) {
      return;
    }

    Form.of(context).save();

    Modular.to.pop();
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
                widget.viewModel.selectedClasses.remove(classOption);
              } else {
                widget.viewModel.selectedClasses.add(classOption);
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
                        widget.viewModel.selectedClasses.remove(classOption);
                      } else {
                        widget.viewModel.selectedClasses.add(classOption);
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
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              StreamBuilder<String>(
                  stream: _nameStreamController.stream,
                  builder: (context, snapshot) {
                    final name =
                        snapshot.data ?? widget.viewModel.nameController.text;
                    return SubjectCard(
                      cardHeight: cardHeight,
                      subject: Subject(
                        name: name,
                        imageUrl: widget.viewModel.imageUrlController.text,
                        classes: widget.viewModel.selectedClasses,
                        teacher: widget.subject != null
                            ? widget.subject!.teacher
                            : '',
                      ),
                      user: UserModel(
                        id: '',
                        name: '',
                        classroom: widget.viewModel.selectedClasses.join(', '),
                        imageUrl: '',
                        isProfessor: false,
                      ),
                      isForm: true,
                    );
                  }),
              const SizedBox(height: 20),
              CustomTextField(
                text: 'Name',
                controller: widget.viewModel.nameController,
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
                            widget.viewModel.selectedClasses
                                .contains(classOptions[firstIndex]),
                            classOptions[firstIndex],
                          ),
                        if (secondIndex < classOptions.length)
                          _buildClassItem(
                            widget.viewModel.selectedClasses
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
      ),
    );
  }
}
