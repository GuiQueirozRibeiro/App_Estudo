import 'package:flutter/material.dart';

class ClassListView extends StatelessWidget {
  final List classOptions;
  final List selectedClasses;
  final Function(bool, String) onClassItemTap;

  const ClassListView({
    super.key,
    required this.selectedClasses,
    required this.onClassItemTap,
    required this.classOptions,
  });

  Widget _buildClassItem(
      bool isChecked, String classOption, BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: isChecked
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        child: InkWell(
          onTap: () {
            onClassItemTap(isChecked, classOption);
          },
          borderRadius: BorderRadius.circular(10.0),
          child: Padding(
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
                    onClassItemTap(!value!, classOption);
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
    return Expanded(
      child: ListView.builder(
        itemCount: (classOptions.length / 2).ceil(),
        itemBuilder: (ctx, index) {
          int firstIndex = index * 2;
          int secondIndex = firstIndex + 1;
          return Row(
            children: [
              if (firstIndex < classOptions.length)
                _buildClassItem(
                  selectedClasses.contains(classOptions[firstIndex]),
                  classOptions[firstIndex],
                  context,
                ),
              if (secondIndex < classOptions.length)
                _buildClassItem(
                  selectedClasses.contains(classOptions[secondIndex]),
                  classOptions[secondIndex],
                  context,
                ),
            ],
          );
        },
      ),
    );
  }
}
