import 'package:flutter/foundation.dart';

import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';
import 'package:billmate/domain/repositories/split_repository.dart';
import 'split_state.dart';

class SplitBloc extends ChangeNotifier {
  SplitBloc({
    required SplitGroupRepository groupRepository,
    required SplitMemberRepository memberRepository,
  })  : _groupRepository = groupRepository,
        _memberRepository = memberRepository,
        state = SplitState();

  final SplitGroupRepository _groupRepository;
  final SplitMemberRepository _memberRepository;
  final SplitState state;

  Future<void> loadGroups() async {
    state.setLoading(true);
    state.clearError();

    try {
      final groups = await _groupRepository.getGroups();
      state.setGroups(groups);

      // Load members for each group
      for (final group in groups) {
        await loadGroupMembers(group.id);
      }
    } catch (e) {
      state.setError('Failed to load groups: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> loadGroupMembers(String groupId) async {
    try {
      final members = await _memberRepository.getMembers(groupId);
      state.setMembers(groupId, members);
    } catch (e) {
      state.setError('Failed to load members: ${e.toString()}');
    }
  }

  Future<void> createGroup(SplitGroupEntity group) async {
    state.setLoading(true);
    state.clearError();

    try {
      final created = await _groupRepository.createGroup(group);
      state.addGroup(created);
      state.setMembers(created.id, []);
    } catch (e) {
      state.setError('Failed to create group: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> updateGroup(SplitGroupEntity group) async {
    state.setLoading(true);
    state.clearError();

    try {
      final updated = await _groupRepository.updateGroup(group);
      state.updateGroup(updated);
      if (state.selectedGroup?.id == group.id) {
        state.setSelectedGroup(updated);
      }
    } catch (e) {
      state.setError('Failed to update group: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    state.setLoading(true);
    state.clearError();

    try {
      await _groupRepository.deleteGroup(groupId);
      state.removeGroup(groupId);
      if (state.selectedGroup?.id == groupId) {
        state.setSelectedGroup(null);
      }
    } catch (e) {
      state.setError('Failed to delete group: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> addMember(String groupId, SplitMemberEntity member) async {
    state.setLoading(true);
    state.clearError();

    try {
      final added = await _memberRepository.addMember(member);
      state.addMember(groupId, added);
    } catch (e) {
      state.setError('Failed to add member: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> updateMember(String groupId, SplitMemberEntity member) async {
    state.setLoading(true);
    state.clearError();

    try {
      final updated = await _memberRepository.updateMember(member);
      state.updateMember(groupId, updated);
    } catch (e) {
      state.setError('Failed to update member: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> removeMember(String groupId, String memberId) async {
    state.setLoading(true);
    state.clearError();

    try {
      await _memberRepository.removeMember(memberId);
      state.removeMember(groupId, memberId);
    } catch (e) {
      state.setError('Failed to remove member: ${e.toString()}');
    } finally {
      state.setLoading(false);
    }
  }

  Future<void> markMemberAsPaid(String memberId, bool isPaid) async {
    state.clearError();

    try {
      await _memberRepository.updateMemberPaymentStatus(memberId, isPaid);
      // Reload to sync state
      final group = state.selectedGroup;
      if (group != null) {
        await loadGroupMembers(group.id);
      }
    } catch (e) {
      state.setError('Failed to update payment status: ${e.toString()}');
    }
  }

  void selectGroup(SplitGroupEntity group) {
    state.setSelectedGroup(group);
  }
}
