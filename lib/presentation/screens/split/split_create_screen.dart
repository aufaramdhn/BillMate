import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:billmate/blocs/split/split_bloc.dart';
import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/config/app_config.dart';

class SplitCreateScreen extends StatefulWidget {
  const SplitCreateScreen({super.key});

  @override
  State<SplitCreateScreen> createState() => _SplitCreateScreenState();
}

class _SplitCreateScreenState extends State<SplitCreateScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Group Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., House Rent',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Group name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Add any notes about this group',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Consumer<SplitBloc>(
                  builder: (context, bloc, _) {
                    return ListenableBuilder(
                      listenable: bloc.state,
                      builder: (context, _) {
                        return ElevatedButton(
                          onPressed: bloc.state.isLoading
                              ? null
                              : () => _handleCreate(context, bloc),
                          child: bloc.state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create Group'),
                        );
                      },
                    );
                  },
                ),
              ),
              if (context.watch<SplitBloc>().state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${context.watch<SplitBloc>().state.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreate(BuildContext context, SplitBloc bloc) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const uuid = Uuid();
    final now = DateTime.now();

    final group = SplitGroupEntity(
      id: uuid.v4(),
      userId: AppConfig.demoUserId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await bloc.createGroup(group);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
