import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/member.dart';
import 'package:gymnex_manage/core/services/member_service.dart';
import 'package:gymnex_manage/features/members/member_detail.dart';
import 'package:gymnex_manage/features/members/member_edit.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final MemberService _memberService = MemberService();
  bool _isGridView = false;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Member List"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberEditScreen(isNewMember: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<List<Member>>(
              stream: _getFilteredMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Members found"));
                }

                final members = snapshot.data!;

                return _isGridView
                    ? _buildGridView(members)
                    : _buildListView(members);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Active', 'active'),
                _buildFilterChip('Inactive', 'inactive'),
                _buildFilterChip('Expired', 'expired'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _statusFilter == value,
        onSelected: (selected) {
          setState(() {
            _statusFilter = value;
          });
        },
      ),
    );
  }

  Stream<List<Member>> _getFilteredMembers() {
    if (_searchQuery.isNotEmpty) {
      return _memberService.searchMembers(_searchQuery);
    } else if (_statusFilter != 'all') {
      return _memberService.getMembersByStatus(_statusFilter);
    } else {
      return _memberService.getMembers();
    }
  }

  Widget _buildListView(List<Member> members) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, i) {
        final member = members[i];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  member.photoUrl.isNotEmpty
                      ? NetworkImage(member.photoUrl)
                      : null,
              child: member.photoUrl.isEmpty ? Text(member.name[0]) : null,
            ),
            title: Text(member.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.email),
                Text('Membership: ${member.membershipPlan}'),
              ],
            ),
            trailing: _buildMemberStatusChip(member.status),
            onTap: () => _navigateToMemberDetail(member),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Member> members) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: members.length,
      itemBuilder: (context, i) {
        final member = members[i];
        return Card(
          child: InkWell(
            onTap: () => _navigateToMemberDetail(member),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      member.photoUrl.isNotEmpty
                          ? NetworkImage(member.photoUrl)
                          : null,
                  child:
                      member.photoUrl.isEmpty
                          ? Text(member.name[0], style: TextStyle(fontSize: 24))
                          : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        member.email,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      _buildMemberStatusChip(member.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberStatusChip(String status) {
    Color chipColor;
    IconData iconData;

    switch (status) {
      case 'active':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'inactive':
        chipColor = Colors.grey;
        iconData = Icons.cancel;
        break;
      case 'expired':
        chipColor = Colors.red;
        iconData = Icons.warning;
        break;
      default:
        chipColor = Colors.blue;
        iconData = Icons.info;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      avatar: Icon(iconData, color: Colors.white, size: 16),
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _navigateToMemberDetail(Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(member: member),
      ),
    );
  }
}
