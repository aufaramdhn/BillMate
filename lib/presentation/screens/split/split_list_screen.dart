import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:billmate/blocs/split/split_bloc.dart';
import 'package:billmate/components/empty_state.dart';

class SplitListScreen extends StatefulWidget {
  const SplitListScreen({super.key});

  @override
  State<SplitListScreen> createState() => _SplitListScreenState();
}

class _SplitListScreenState extends State<SplitListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplitBloc>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill Groups'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/split/create');
        },
        tooltip: 'New Group',
        child: const Icon(Icons.add),
      ),
      body: Consumer<SplitBloc>(
        builder: (context, bloc, _) {
          return ListenableBuilder(
            listenable: bloc.state,
            builder: (context, _) {
              if (bloc.state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bloc.state.error != null) {
                return Center(
                  child: Text(
                    'Error: ${bloc.state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final groups = bloc.state.groups;
              if (groups.isEmpty) {
                return const EmptyState(
                  title: 'No Groups',
                  description: 'Create your first split bill group',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final members = bloc.state.membersByGroup[group.id] ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${members.length} anggota',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        bloc.selectGroup(group);
                        Navigator.pushNamed(
                          context,
                          '/split/detail',
                          arguments: group.id,
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
