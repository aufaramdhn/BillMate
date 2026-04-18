import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';

abstract class SplitGroupRepository {
  Future<List<SplitGroupEntity>> getGroups();

  Future<SplitGroupEntity> createGroup(SplitGroupEntity group);

  Future<SplitGroupEntity> updateGroup(SplitGroupEntity group);

  Future<void> deleteGroup(String groupId);

  Future<SplitGroupEntity?> getGroupById(String groupId);
}

abstract class SplitMemberRepository {
  Future<List<SplitMemberEntity>> getMembers(String groupId);

  Future<SplitMemberEntity> addMember(SplitMemberEntity member);

  Future<SplitMemberEntity> updateMember(SplitMemberEntity member);

  Future<void> removeMember(String memberId);

  Future<SplitMemberEntity?> getMemberById(String memberId);

  Future<void> updateMemberPaymentStatus(String memberId, bool isPaid);
}
