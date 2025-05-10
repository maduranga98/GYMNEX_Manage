// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/member.dart';
import 'package:gymnex_manage/core/services/member_service.dart';
import 'package:intl/intl.dart';

class MemberEditScreen extends StatefulWidget {
  final bool isNewMember;
  final Member? member;

  const MemberEditScreen({super.key, required this.isNewMember, this.member});

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberService = MemberService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _photoUrlController;
  late DateTime _joinDate;
  String _selectedType = 'Regular';
  String _selectedStatus = 'active';
  String _selectedMembershipPlan = 'Basic Plan';
  DateTime? _membershipExpiryDate;
  Map<String, dynamic> _additionalInfo = {};

  final List<String> _memberTypes = [
    'Regular',
    'VIP',
    'Student',
    'Senior',
    'Staff',
  ];
  final List<String> _memberStatus = ['active', 'inactive', 'expired'];
  final List<String> _membershipPlans = [
    'Basic Plan',
    'Premium Plan',
    'Platinum Plan',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.isNewMember) {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _photoUrlController = TextEditingController();
      _joinDate = DateTime.now();
      _membershipExpiryDate = DateTime.now().add(Duration(days: 30));
    } else {
      final member = widget.member!;
      _nameController = TextEditingController(text: member.name);
      _emailController = TextEditingController(text: member.email);
      _phoneController = TextEditingController(text: member.phone);
      _photoUrlController = TextEditingController(text: member.photoUrl);
      _joinDate = member.joinDate;
      _selectedType = member.type;
      _selectedStatus = member.status;
      _selectedMembershipPlan = member.membershipPlan;
      _membershipExpiryDate = member.membershipExpiryDate;
      _additionalInfo = Map<String, dynamic>.from(member.additionalInfo);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewMember ? 'Add New Member' : 'Edit Member'),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.save, color: Colors.white),
            label: Text('Save', style: TextStyle(color: Colors.white)),
            onPressed: _saveMember,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfoSection(),
              SizedBox(height: 24),
              _buildMembershipSection(),
              SizedBox(height: 24),
              _buildAdditionalInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the member\'s name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _photoUrlController,
              decoration: InputDecoration(
                labelText: 'Photo URL (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.photo),
              ),
            ),
            SizedBox(height: 16),
            _buildDatePicker(
              label: 'Join Date',
              selectedDate: _joinDate,
              onDateSelected: (date) {
                setState(() {
                  _joinDate = date;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Member Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  _memberTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Member Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.circle),
              ),
              items:
                  _memberStatus.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMembershipPlan,
              decoration: InputDecoration(
                labelText: 'Membership Plan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.card_membership),
              ),
              items:
                  _membershipPlans.map((plan) {
                    return DropdownMenuItem(value: plan, child: Text(plan));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMembershipPlan = value!;
                });
              },
            ),
            SizedBox(height: 16),
            _buildDatePicker(
              label: 'Membership Expiry Date',
              selectedDate:
                  _membershipExpiryDate ??
                  DateTime.now().add(Duration(days: 30)),
              onDateSelected: (date) {
                setState(() {
                  _membershipExpiryDate = date;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    // This could be expanded to include dynamic fields
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Additional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add Field'),
                  onPressed: _showAddFieldDialog,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_additionalInfo.isEmpty)
              Center(
                child: Text(
                  'No additional information',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._additionalInfo.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value.toString(),
                          decoration: InputDecoration(
                            labelText: entry.key,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _additionalInfo[entry.key] = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _additionalInfo.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
      ),
    );
  }

  void _showAddFieldDialog() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Custom Field'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: keyController,
                  decoration: InputDecoration(
                    labelText: 'Field Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Field Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (keyController.text.isNotEmpty) {
                    setState(() {
                      _additionalInfo[keyController.text] =
                          valueController.text;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      if (widget.isNewMember) {
        final newMember = Member(
          id: '', // This will be set by Firestore
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          type: _selectedType,
          joinDate: _joinDate,
          status: _selectedStatus,
          photoUrl: _photoUrlController.text,
          membershipPlan: _selectedMembershipPlan,
          membershipExpiryDate: _membershipExpiryDate,
          additionalInfo: _additionalInfo,
        );

        _memberService
            .addMember(newMember)
            .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Member added successfully')),
              );
              Navigator.pop(context, true);
            })
            .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding member: $error')),
              );
            });
      } else {
        final updatedMember = widget.member!.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          type: _selectedType,
          joinDate: _joinDate,
          status: _selectedStatus,
          photoUrl: _photoUrlController.text,
          membershipPlan: _selectedMembershipPlan,
          membershipExpiryDate: _membershipExpiryDate,
          additionalInfo: _additionalInfo,
        );

        _memberService
            .updateMember(updatedMember)
            .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Member updated successfully')),
              );
              Navigator.pop(context, true);
            })
            .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating member: $error')),
              );
            });
      }
    }
  }
}
