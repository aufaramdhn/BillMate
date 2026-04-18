import 'package:flutter/foundation.dart';

import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';

class SplitState with ChangeNotifier {
  List<SplitGroupEntity> groups = [];
  Map<String, List<SplitMemberEntity>> membersByGroup = {};
  SplitGroupEntity? selectedGroup;
  bool isLoading = false;
  String? error;

  void setGroups(List<SplitGroupEntity> newGroups) {
    groups = newGroups;
    notifyListeners();
  }

  void setMembers(String groupId, List<SplitMemberEntity> members) {
    membersByGroup[groupId] = members;
    notifyListeners();
  }

  void setSelectedGroup(SplitGroupEntity? group) {
    selectedGroup = group;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setError(String? errorMsg) {
    error = errorMsg;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void addGroup(SplitGroupEntity group) {
    groups = [...groups, group];
    notifyListeners();
  }

  void updateGroup(SplitGroupEntity group) {
    final index = groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      groups = [...groups];
      groups[index] = group;
      notifyListeners();
    }
  }

  void removeGroup(String groupId) {
    groups = groups.where((g) => g.id != groupId).toList();
    membersByGroup.remove(groupId);
    notifyListeners();
  }

  void addMember(String groupId, SplitMemberEntity member) {
    final members = membersByGroup[groupId] ?? [];
    membersByGroup[groupId] = [...members, member];
    notifyListeners();
  }

  void updateMember(String groupId, SplitMemberEntity member) {
    final members = membersByGroup[groupId] ?? [];
    final index = members.indexWhere((m) => m.id == member.id);
    if (index >= 0) {
      membersByGroup[groupId] = [...members];
      membersByGroup[groupId]![index] = member;
      notifyListeners();
    }
  }

  void removeMember(String groupId, String memberId) {
    final members = membersByGroup[groupId] ?? [];
    membersByGroup[groupId] = members.where((m) => m.id != memberId).toList();
    notifyListeners();
  }
}
