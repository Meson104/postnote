import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/notes_cubit.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const NotesPage());

  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  Color selectedColor = Color.fromRGBO(246, 222, 194, 1);
  final _formKey = GlobalKey<FormState>();

  void createNote() async {
    if (_formKey.currentState!.validate()) {
      AuthLoggedIn user = await context.read<AuthCubit>().state as AuthLoggedIn;
      await context.read<NotesCubit>().createNewNote(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        token: user.user.token,
        color: selectedColor,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

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
      body: BlocConsumer<NotesCubit, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is NotesSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Note posted')));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(hintText: 'Title'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: 'Start writing...'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Content cannot be empty';
                        }
                        return null;
                      },
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
                      onPressed: createNote,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
