import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:billmate/blocs/split/split_bloc.dart';
import 'package:billmate/components/empty_state.dart';

class SplitDetailScreen extends StatefulWidget {
  const SplitDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  State<SplitDetailScreen> createState() => _SplitDetailScreenState();
}

class _SplitDetailScreenState extends State<SplitDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplitBloc>().loadGroupMembers(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/split/edit',
                arguments: widget.groupId,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/split/add-member',
            arguments: widget.groupId,
          );
        },
        tooltip: 'Add Member',
        child: const Icon(Icons.person_add),
      ),
      body: Consumer<SplitBloc>(
        builder: (context, bloc, _) {
          return ListenableBuilder(
            listenable: bloc.state,
            builder: (context, _) {
              if (bloc.state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = bloc.state.membersByGroup[widget.groupId] ?? [];

              if (members.isEmpty) {
                return const EmptyState(
                  title: 'No Members',
                  description: 'Add members to start splitting bills',
                );
              }

              double totalShare = members.fold(0, (sum, m) => sum + m.sharePercentage);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Share',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalShare%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          if (totalShare != 100)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                totalShare > 100
                                    ? 'Over-allocation: ${(totalShare - 100).toStringAsFixed(1)}%'
                                    : 'Under-allocation: ${(100 - totalShare).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: totalShare > 100 ? Colors.red : Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...members.map((member) {
                    return _buildMemberCard(context, bloc, member);
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, SplitBloc bloc, dynamic member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(member.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Share: ${member.sharePercentage}%'),
            if (member.email != null)
              Text(
                'Email: ${member.email}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/split/edit-member',
                  arguments: {'groupId': widget.groupId, 'memberId': member.id},
                );
              },
            ),
            PopupMenuItem(
              child: const Text('Mark Paid'),
              onTap: () {
                bloc.markMemberAsPaid(member.id, !member.isPaid);
              },
            ),
            PopupMenuItem(
              child: const Text('Remove'),
              onTap: () {
                bloc.removeMember(widget.groupId, member.id);
              },
            ),
          ],
        ),
        isThreeLine: member.email != null,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SplitBloc>().deleteGroup(widget.groupId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
