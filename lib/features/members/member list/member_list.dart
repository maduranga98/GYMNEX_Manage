import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Member List")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("members").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Members found"));
          }
          final members = snapshot.data!.docs;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, i) {
              final memberData = members[i].data();
              return Card(
                child: Column(
                  children: [
                    Text("${memberData["name"]}"),
                    Text("Joined Date: ${memberData["date"]}"),
                    Text("Email: ${memberData["email"]}"),
                    Text("Phone: ${memberData["phone"]}"),
                    Text("Type: ${memberData["type"]}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
