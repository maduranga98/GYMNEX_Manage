import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/member.dart';
import 'package:gymnex_manage/core/services/member_service.dart';
import 'package:gymnex_manage/features/members/member_edit.dart';
import 'package:intl/intl.dart';

class MemberDetailScreen extends StatefulWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MemberService _memberService = MemberService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Member Profile'),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: () => _editMember()),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteMember(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Info', icon: Icon(Icons.person)),
            Tab(text: 'Membership', icon: Icon(Icons.card_membership)),
            Tab(text: 'Attendance', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Performance', icon: Icon(Icons.show_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildMembershipTab(),
          _buildAttendanceTab(),
          _buildPerformanceTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      widget.member.photoUrl.isNotEmpty
                          ? NetworkImage(widget.member.photoUrl)
                          : null,
                  child:
                      widget.member.photoUrl.isEmpty
                          ? Text(
                            widget.member.name[0],
                            style: TextStyle(fontSize: 40),
                          )
                          : null,
                ),
                SizedBox(height: 16),
                Text(
                  widget.member.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildStatusBadge(widget.member.status),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.email, 'Email', widget.member.email),
            Divider(),
            _buildInfoRow(Icons.phone, 'Phone', widget.member.phone),
            Divider(),
            _buildInfoRow(Icons.category, 'Type', widget.member.type),
            Divider(),
            _buildInfoRow(
              Icons.date_range,
              'Joined Date',
              dateFormat.format(widget.member.joinDate),
            ),
            if (widget.member.additionalInfo.isNotEmpty) ...[
              Divider(),
              Text(
                'Additional Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...widget.member.additionalInfo.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(child: Text('${entry.value}')),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipTab() {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Membership',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.card_membership,
                    'Plan',
                    widget.member.membershipPlan,
                  ),
                  Divider(),
                  _buildInfoRow(
                    Icons.event,
                    'Expiry Date',
                    widget.member.membershipExpiryDate != null
                        ? dateFormat.format(widget.member.membershipExpiryDate!)
                        : 'Not specified',
                  ),
                  Divider(),
                  _buildInfoRow(
                    Icons.circle,
                    'Status',
                    widget.member.status.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Renewal Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildMembershipOptions(),
        ],
      ),
    );
  }

  Widget _buildMembershipOptions() {
    return Column(
      children: [
        _buildMembershipOptionCard(
          'Basic Plan',
          'Monthly access to basic facilities',
          '\$29.99/month',
          1,
        ),
        SizedBox(height: 12),
        _buildMembershipOptionCard(
          'Premium Plan',
          'Full access to all facilities and classes',
          '\$49.99/month',
          3,
        ),
        SizedBox(height: 12),
        _buildMembershipOptionCard(
          'Platinum Plan',
          'VIP access and personal training sessions',
          '\$99.99/month',
          6,
        ),
      ],
    );
  }

  Widget _buildMembershipOptionCard(
    String title,
    String description,
    String price,
    int monthsToAdd,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _renewMembership(title, monthsToAdd),
              child: Text('Renew'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _memberService.getAttendanceRecords(widget.member.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No attendance records found',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add Attendance'),
                  onPressed: () => _addAttendanceRecord(),
                ),
              ],
            ),
          );
        }

        final records = snapshot.data!.docs;
        final dateFormat = DateFormat('MMM d, yyyy - hh:mm a');

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add, size: 18),
                    label: Text('Add'),
                    onPressed: () => _addAttendanceRecord(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index].data() as Map<String, dynamic>;
                  final date = (record['date'] as Timestamp).toDate();
                  final present = record['present'] as bool;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        present ? Icons.check_circle : Icons.cancel,
                        color: present ? Colors.green : Colors.red,
                      ),
                      title: Text(dateFormat.format(date)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed:
                            () => _deleteAttendanceRecord(records[index].id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _memberService.getPerformanceRecords(widget.member.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No performance records found',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add Performance Record'),
                  onPressed: () => _addPerformanceRecord(),
                ),
              ],
            ),
          );
        }

        final records = snapshot.data!.docs;
        final dateFormat = DateFormat('MMM d, yyyy');

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add, size: 18),
                    label: Text('Add'),
                    onPressed: () => _addPerformanceRecord(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index].data() as Map<String, dynamic>;
                  final date = (record['date'] as Timestamp).toDate();
                  final metrics = record['metrics'] as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateFormat.format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed:
                                    () => _deletePerformanceRecord(
                                      records[index].id,
                                    ),
                              ),
                            ],
                          ),
                          Divider(),
                          ...metrics.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    '${entry.value}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String label;

    switch (status) {
      case 'active':
        badgeColor = Colors.green;
        label = 'ACTIVE';
        break;
      case 'inactive':
        badgeColor = Colors.grey;
        label = 'INACTIVE';
        break;
      case 'expired':
        badgeColor = Colors.red;
        label = 'EXPIRED';
        break;
      default:
        badgeColor = Colors.blue;
        label = status.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _editMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                MemberEditScreen(isNewMember: false, member: widget.member),
      ),
    ).then((updated) {
      if (updated == true) {
        // Refresh member data
        _memberService.getMember(widget.member.id).then((updatedMember) {
          if (updatedMember != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MemberDetailScreen(member: updatedMember),
              ),
            );
          }
        });
      }
    });
  }

  void _deleteMember() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Member'),
            content: Text(
              'Are you sure you want to delete ${widget.member.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _memberService
                      .deleteMember(widget.member.id)
                      .then((_) {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to member list
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Member deleted successfully'),
                          ),
                        );
                      })
                      .catchError((error) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting member: $error'),
                          ),
                        );
                      });
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _renewMembership(String plan, int monthsToAdd) {
    final now = DateTime.now();
    final expiryDate = DateTime(now.year, now.month + monthsToAdd, now.day);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Membership Renewal'),
            content: Text(
              'Renew ${widget.member.name}\'s membership to "$plan" until ${DateFormat('MMM d, yyyy').format(expiryDate)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _memberService
                      .updateMembershipPlan(widget.member.id, plan, expiryDate)
                      .then((_) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Membership renewed successfully'),
                          ),
                        );
                        // Refresh member data
                        _memberService.getMember(widget.member.id).then((
                          updatedMember,
                        ) {
                          if (updatedMember != null && mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MemberDetailScreen(
                                      member: updatedMember,
                                    ),
                              ),
                            );
                          }
                        });
                      })
                      .catchError((error) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error renewing membership: $error'),
                          ),
                        );
                      });
                },
                child: Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _addAttendanceRecord() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Attendance Record'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mark ${widget.member.name} as present for today?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _memberService
                      .addAttendanceRecord(widget.member.id, DateTime.now())
                      .then((_) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Attendance recorded successfully'),
                          ),
                        );
                      })
                      .catchError((error) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error recording attendance: $error'),
                          ),
                        );
                      });
                },
                child: Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _deleteAttendanceRecord(String recordId) {
    FirebaseFirestore.instance
        .collection('members')
        .doc(widget.member.id)
        .collection('attendance')
        .doc(recordId)
        .delete()
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Attendance record deleted')));
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting record: $error')),
          );
        });
  }

  void _addPerformanceRecord() {
    // This would typically be a form with multiple metrics
    // For simplicity, we'll just add a basic record
    final metrics = {
      'Weight': '75 kg',
      'Body Fat': '15%',
      'Bench Press': '80 kg',
      'Squat': '120 kg',
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Performance Record'),
            content: Text(
              'Add a new performance record for ${widget.member.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _memberService
                      .addPerformanceRecord(
                        widget.member.id,
                        DateTime.now(),
                        metrics,
                      )
                      .then((_) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Performance recorded successfully'),
                          ),
                        );
                      })
                      .catchError((error) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error recording performance: $error',
                            ),
                          ),
                        );
                      });
                },
                child: Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _deletePerformanceRecord(String recordId) {
    FirebaseFirestore.instance
        .collection('members')
        .doc(widget.member.id)
        .collection('performance')
        .doc(recordId)
        .delete()
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Performance record deleted')));
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting record: $error')),
          );
        });
  }
}
