import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:billmate/blocs/split/split_bloc.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';
import 'package:billmate/domain/services/onesignal_service.dart';

class SplitAddMemberScreen extends StatefulWidget {
  const SplitAddMemberScreen({required this.groupId, super.key});

  final String groupId;

  @override
  State<SplitAddMemberScreen> createState() => _SplitAddMemberScreenState();
}

class _SplitAddMemberScreenState extends State<SplitAddMemberScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _shareController = TextEditingController(text: '50');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
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
                'Member Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., John Doe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Email (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'john@example.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@')) {
                      return 'Invalid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Share Percentage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _shareController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '50',
                  suffix: const Text('%'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Share percentage is required';
                  }
                  final share = double.tryParse(value);
                  if (share == null || share <= 0 || share > 100) {
                    return 'Share must be between 0 and 100';
                  }
                  return null;
                },
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
                          onPressed: bloc.state.isLoading ? null : () => _handleAdd(context, bloc),
                          child: bloc.state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add Member'),
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
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdd(BuildContext context, SplitBloc bloc) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const uuid = Uuid();
    final now = DateTime.now();

    final member = SplitMemberEntity(
      id: uuid.v4(),
      groupId: widget.groupId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      sharePercentage: double.parse(_shareController.text),
      createdAt: now,
      updatedAt: now,
    );

    await bloc.addMember(widget.groupId, member);

    // Send OneSignal notification to member if email provided
    if (member.email != null) {
      await OneSignalService.sendReminder(
        recipientEmail: member.email!,
        title: 'Added to Split Bill Group',
        body: 'You have been added to a split bill group. Your share: ${member.sharePercentage}%',
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
