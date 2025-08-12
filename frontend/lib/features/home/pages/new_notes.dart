import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewNotes extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const NewNotes());

  const NewNotes({super.key});

  @override
  State<NewNotes> createState() => _NewNotesState();
}

class _NewNotesState extends State<NewNotes> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  Color selectedColor = Color.fromRGBO(246, 222, 194, 1);
  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Note'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text((DateFormat('dd/MM/yyyy').format(date))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Start writing...'),
            ),
            const SizedBox(height: 10),
            ColorPicker(
              heading: const Text('Select color'),
              subheading: const Text('shades'),
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
