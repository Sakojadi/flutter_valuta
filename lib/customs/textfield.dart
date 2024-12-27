import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isValid;
  final TextInputType keyboardType;
  final Function onChanged;
  final TextInputFormatter? inputFormatter;

  CustomTextField({
    required this.controller,
    required this.label,
    required this.isValid,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatter != null ? [inputFormatter!] : null,
      onChanged: (value) => onChanged(value),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF193441)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isValid ? Color(0xFF193441) : Colors.red),
        ),
      ),
    );
  }
}

// Custom Dropdown Widget
class CustomDropdown extends StatelessWidget {
  final String? selectedItem;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isValid;

  const CustomDropdown({
    Key? key,
    required this.selectedItem,
    required this.items,
    required this.onChanged,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: !isValid ? Colors.red : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: selectedItem,
        hint: Text('Select an option'),
        isExpanded: true,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
