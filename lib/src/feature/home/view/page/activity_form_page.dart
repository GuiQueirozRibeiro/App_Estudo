import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_text_field.dart';
import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/activity.dart';
import '../../repository/activity_list.dart';
import '../widget/activity_card.dart';
import '../widget/class_list_view.dart';
import '../widget/date_picker.dart';

class ActivityFormPage extends StatefulWidget {
  const ActivityFormPage({
    super.key,
  });

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  bool _isLoading = false;
  List _selectedClasses = [];

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object?>{};
  final _descriptionController = TextEditingController();
  late final UserModel? currentUser;

  @override
  void initState() {
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    currentUser = authProvider.currentUser;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg != null) {
      final activity = arg as Activity;
      _formData['id'] = activity.id;
      _formData['description'] = activity.description;
      _formData['subjectId'] = activity.subjectId;
      _formData['professorId'] = activity.user.id;
      _formData['classes'] = activity.classes;
      _formData['assignedDate'] = activity.assignedDate;
      _formData['dueDate'] = activity.dueDate;

      _selectedClasses = activity.classes.toList();
      _descriptionController.text = _formData['description']?.toString() ?? '';
    }
  }

  void updateDatePicker(DateTime? pickedDate) {
    setState(() {
      _formData['dueDate'] = pickedDate;
    });
  }

  void updateSelectedClasses(bool isChecked, String classOption) {
    setState(() {
      if (isChecked) {
        _selectedClasses.remove(classOption);
      } else {
        _selectedClasses.add(classOption);
      }
      _formData['classes'] = _selectedClasses;
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('error_occurred'.i18n()),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.i18n()),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    final activityProvider = Provider.of<ActivityList>(context, listen: false);

    try {
      await activityProvider.saveActivity(_formData, currentUser!);
    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      Modular.to.pop();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('activity_form'.i18n()),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    ActivityCard(
                      activity: Activity(
                        id: '',
                        user: currentUser!,
                        subjectId: '',
                        classes: _selectedClasses,
                        description: _descriptionController.text,
                        assignedDate: Timestamp.fromDate(
                            _formData['assignedDate'] as DateTime? ??
                                DateTime.now()),
                      ),
                      isForm: true,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CustomTextField(
                        text: 'description_field'.i18n(),
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        onSaved: (description) =>
                            _formData['description'] = description ?? '',
                        validator: (userDescription) {
                          final description = userDescription ?? '';

                          if (description.trim().isEmpty) {
                            return 'description_required'.i18n();
                          }

                          if (description.trim().length < 10) {
                            return 'description_invalid'.i18n();
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    DatePicker(
                      selectedDate: _formData['dueDate'] as DateTime?,
                      onDateChanged: updateDatePicker,
                    ),
                    const SizedBox(height: 10),
                    ClassListView(
                      selectedClasses: _selectedClasses,
                      onClassItemTap: updateSelectedClasses,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
