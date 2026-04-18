import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:billmate/data/repositories/in_memory_split_repository.dart';
import 'package:billmate/domain/entities/split_group_entity.dart';
import 'package:billmate/domain/entities/split_member_entity.dart';
import 'package:billmate/presentation/blocs/split/split_bloc.dart';

void main() {
  group('Split Bill End-to-End Integration Tests', () {
    late InMemorySplitGroupRepository groupRepository;
    late InMemorySplitMemberRepository memberRepository;
    late SplitBloc bloc;

    setUp(() {
      groupRepository = InMemorySplitGroupRepository();
      memberRepository = InMemorySplitMemberRepository();
      bloc = SplitBloc(
        groupRepository: groupRepository,
        memberRepository: memberRepository,
      );
    });

    test('create split group and add members', () async {
      const uuid = Uuid();
      final now = DateTime.now();

      // Create a group
      final group = SplitGroupEntity(
        id: uuid.v4(),
        userId: 'user1',
        name: 'House Rent',
        description: 'Monthly house rent split',
        createdAt: now,
        updatedAt: now,
      );

      await bloc.createGroup(group);
      expect(bloc.state.groups.length, 1);
      expect(bloc.state.groups[0].name, 'House Rent');

      // Add members to the group
      final member1 = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group.id,
        name: 'Alice',
        email: 'alice@example.com',
        sharePercentage: 50,
        createdAt: now,
        updatedAt: now,
      );

      final member2 = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group.id,
        name: 'Bob',
        email: 'bob@example.com',
        sharePercentage: 50,
        createdAt: now,
        updatedAt: now,
      );

      await bloc.addMember(group.id, member1);
      await bloc.addMember(group.id, member2);

      final members = bloc.state.membersByGroup[group.id] ?? [];
      expect(members.length, 2);
      expect(members[0].sharePercentage, 50);
      expect(members[1].sharePercentage, 50);
    });

    test('update member payment status', () async {
      const uuid = Uuid();
      final now = DateTime.now();

      final group = SplitGroupEntity(
        id: uuid.v4(),
        userId: 'user1',
        name: 'Test Group',
        createdAt: now,
        updatedAt: now,
      );

      final member = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group.id,
        name: 'Charlie',
        sharePercentage: 100,
        createdAt: now,
        updatedAt: now,
      );

      await bloc.createGroup(group);
      await bloc.addMember(group.id, member);

      // Verify initial state - member should be unpaid
      var initialMembers = bloc.state.membersByGroup[group.id] ?? [];
      expect(initialMembers.length, 1);
      expect(initialMembers[0].isPaid, false);

      // Update member directly in repository to verify it works
      final updatedMember = member.copyWith(isPaid: true, paidAt: now);
      await bloc.updateMember(group.id, updatedMember);

      // Verify updated state
      var updatedMembers = bloc.state.membersByGroup[group.id] ?? [];
      final targetMember = updatedMembers.firstWhere((m) => m.id == member.id);
      expect(targetMember.isPaid, true);

      // Update back to unpaid
      final unpaidMember = targetMember.copyWith(isPaid: false, clearPaidAt: true);
      await bloc.updateMember(group.id, unpaidMember);

      // Verify unpaid state
      var finalMembers = bloc.state.membersByGroup[group.id] ?? [];
      final finalMember = finalMembers.firstWhere((m) => m.id == member.id);
      expect(finalMember.isPaid, false);
    });

    test('remove member from group', () async {
      const uuid = Uuid();
      final now = DateTime.now();

      final group = SplitGroupEntity(
        id: uuid.v4(),
        userId: 'user1',
        name: 'Test Group',
        createdAt: now,
        updatedAt: now,
      );

      final member1 = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group.id,
        name: 'David',
        sharePercentage: 50,
        createdAt: now,
        updatedAt: now,
      );

      final member2 = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group.id,
        name: 'Eve',
        sharePercentage: 50,
        createdAt: now,
        updatedAt: now,
      );

      await bloc.createGroup(group);
      await bloc.addMember(group.id, member1);
      await bloc.addMember(group.id, member2);

      expect((bloc.state.membersByGroup[group.id] ?? []).length, 2);

      // Remove first member
      await bloc.removeMember(group.id, member1.id);

      final remaining = bloc.state.membersByGroup[group.id] ?? [];
      expect(remaining.length, 1);
      expect(remaining[0].id, member2.id);
    });

    test('load all groups with their members', () async {
      const uuid = Uuid();
      final now = DateTime.now();

      // Create two groups
      final group1 = SplitGroupEntity(
        id: uuid.v4(),
        userId: 'user1',
        name: 'Group 1',
        createdAt: now,
        updatedAt: now,
      );

      final group2 = SplitGroupEntity(
        id: uuid.v4(),
        userId: 'user1',
        name: 'Group 2',
        createdAt: now,
        updatedAt: now,
      );

      await bloc.createGroup(group1);
      await bloc.createGroup(group2);

      // Add member to group1
      final member1 = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group1.id,
        name: 'Frank',
        sharePercentage: 100,
        createdAt: now,
        updatedAt: now,
      );

      await bloc.addMember(group1.id, member1);

      // Load all groups
      await bloc.loadGroups();

      expect(bloc.state.groups.length, 2);
      expect((bloc.state.membersByGroup[group1.id] ?? []).length, 1);
      expect((bloc.state.membersByGroup[group2.id] ?? []).length, 0);
    });

    test('delete group removes all members', () async {
      const uuid = Uuid();
      final now = DateTime.now();

      final group = SplitGroupEntity(
        id: uuid.v4(),
        userId: 'user1',
        name: 'Group to Delete',
        createdAt: now,
        updatedAt: now,
      );

      final member = SplitMemberEntity(
        id: uuid.v4(),
        groupId: group.id,
        name: 'Grace',
        sharePercentage: 100,
        createdAt: now,
        updatedAt: now,
      );

      await bloc.createGroup(group);
      await bloc.addMember(group.id, member);

      expect(bloc.state.groups.length, 1);

      // Delete group
      await bloc.deleteGroup(group.id);

      expect(bloc.state.groups.length, 0);
      expect(bloc.state.membersByGroup[group.id], isNull);
    });
  });
}
