import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';
import 'package:billmate/domain/repositories/split_repository.dart';

class InMemorySplitGroupRepository implements SplitGroupRepository {
  final List<SplitGroupEntity> _groups = <SplitGroupEntity>[];

  @override
  Future<List<SplitGroupEntity>> getGroups() async {
    return List<SplitGroupEntity>.unmodifiable(_groups);
  }

  @override
  Future<SplitGroupEntity> createGroup(SplitGroupEntity group) async {
    _groups.add(group);
    return group;
  }

  @override
  Future<SplitGroupEntity> updateGroup(SplitGroupEntity group) async {
    final index = _groups.indexWhere((item) => item.id == group.id);
    if (index < 0) {
      throw StateError('Group with id ${group.id} was not found.');
    }
    _groups[index] = group;
    return group;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    _groups.removeWhere((item) => item.id == groupId);
  }

  @override
  Future<SplitGroupEntity?> getGroupById(String groupId) async {
    try {
      return _groups.firstWhere((item) => item.id == groupId);
    } catch (_) {
      return null;
    }
  }
}

class InMemorySplitMemberRepository implements SplitMemberRepository {
  final List<SplitMemberEntity> _members = <SplitMemberEntity>[];

  @override
  Future<List<SplitMemberEntity>> getMembers(String groupId) async {
    return _members.where((item) => item.groupId == groupId).toList();
  }

  @override
  Future<SplitMemberEntity> addMember(SplitMemberEntity member) async {
    _members.add(member);
    return member;
  }

  @override
  Future<SplitMemberEntity> updateMember(SplitMemberEntity member) async {
    final index = _members.indexWhere((item) => item.id == member.id);
    if (index < 0) {
      throw StateError('Member with id ${member.id} was not found.');
    }
    _members[index] = member;
    return member;
  }

  @override
  Future<void> removeMember(String memberId) async {
    _members.removeWhere((item) => item.id == memberId);
  }

  @override
  Future<SplitMemberEntity?> getMemberById(String memberId) async {
    try {
      return _members.firstWhere((item) => item.id == memberId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateMemberPaymentStatus(String memberId, bool isPaid) async {
    final index = _members.indexWhere((item) => item.id == memberId);
    if (index >= 0) {
      _members[index] = _members[index].copyWith(
        isPaid: isPaid,
        paidAt: isPaid ? DateTime.now() : null,
        clearPaidAt: !isPaid,
      );
    }
  }
}
