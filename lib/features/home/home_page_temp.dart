import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gymnex_manage/features/members/member%20list/member_list.dart';
import 'package:gymnex_manage/features/profilles/setup/setup.dart';
import 'package:gymnex_manage/features/profilles/templates/template1.dart';
import 'package:gymnex_manage/features/profilles/templates/template2.dart';
import 'package:gymnex_manage/features/profilles/templates/template3.dart';
import 'package:gymnex_manage/features/profilles/templates/template4.dart';
import 'package:gymnex_manage/features/profilles/templates/template5.dart';
import 'package:gymnex_manage/features/schedules/schedule_list_screen.dart';

class HomePageTemp extends StatefulWidget {
  const HomePageTemp({super.key});

  @override
  State<HomePageTemp> createState() => _HomePageTempState();
}

class _HomePageTempState extends State<HomePageTemp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GymNex")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemberList()),
                ),
            child: Text("Member List"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScheduleListScreen()),
                ),
            child: Text("Create Scadules"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setup()),
                ),
            child: Text("SetUp Profile"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Template1()),
                ),
            child: Text("Template1"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Template2()),
                ),
            child: Text("Template2"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Template3()),
                ),
            child: Text("Template3"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Template4()),
                ),
            child: Text("Template4"),
          ),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Template5()),
                ),
            child: Text("Template5"),
          ),
        ],
      ),
    );
  }
}
