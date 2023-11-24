import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkTrackingPage extends StatefulWidget {
  const WorkTrackingPage({super.key});

  @override
  State<WorkTrackingPage> createState() => _WorkTrackingPageState();
}

class _WorkTrackingPageState extends State<WorkTrackingPage> {
  TextEditingController workTextController = TextEditingController();
  TextEditingController hoursTextController = TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> workHistory = [];
  bool enableNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadWorkHistory();
    _loadNotificationSetting();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String? payload) async {
    // Handle notification tap here
  }

  Future<void> _loadWorkHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String historyString = prefs.getString('work_history') ?? '[]';
    setState(() {
      workHistory = List<Map<String, dynamic>>.from(
        json.decode(historyString),
      );
    });
  }

  Future<void> _saveWorkHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('work_history', json.encode(workHistory));
  }

  Future<void> _loadNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notificationSetting = prefs.getBool('enable_notifications') ?? true;
    setState(() {
      enableNotifications = notificationSetting;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', value);
  }

  Future<void> scheduleNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'work_tracker_channel',
      'Work Tracker Notifications',
      channelDescription: 'Notifications for Work Tracker',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'app_icon',
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    int totalHours = workHistory
        .where((entry) =>
            DateTime.parse(entry['timestamp']).day == DateTime.now().day)
        .map<int>((entry) => entry['hours'] as int)
        .fold(0, (sum, hours) => sum + hours);

    if (totalHours < 6 && enableNotifications) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Reminder',
        'You have not worked enough hours today! Total hours: $totalHours',
        platformChannelSpecifics,
        payload: 'item x',
      );
    }
  }

  Future<void> scheduleReminderNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'work_tracker_channel',
      'Work Tracker Notifications',
      channelDescription: 'Notifications for Work Tracker',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'app_icon',
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Reminder',
      'Don\'t forget to log your work today!',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void deleteWorkEntry(int index) {
    setState(() {
      workHistory.removeAt(index);
    });
    _saveWorkHistory();
  }

  void clearAllWorkHistory() {
    setState(() {
      workHistory.clear();
    });
    _saveWorkHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Work Tracking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable Notifications'),
                Switch(
                  value: enableNotifications,
                  onChanged: (value) {
                    setState(() {
                      enableNotifications = value;
                      _saveNotificationSetting(value);
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: workTextController,
              decoration: const InputDecoration(labelText: 'Work Done'),
            ),
            TextField(
              controller: hoursTextController,
              decoration: const InputDecoration(labelText: 'Hours Spent'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                int hours = int.tryParse(hoursTextController.text) ?? 0;
                if (hours < 6 && enableNotifications) {
                  scheduleNotification();
                }

                Map<String, dynamic> entry = {
                  'work': workTextController.text,
                  'hours': hours,
                  'timestamp': DateTime.now().toIso8601String(),
                };

                setState(() {
                  workHistory.add(entry);
                });

                _saveWorkHistory();

                workTextController.clear();
                hoursTextController.clear();

                scheduleReminderNotification();
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Work History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: workHistory.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(workHistory[index]['timestamp']),
                    onDismissed: (direction) => deleteWorkEntry(index),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      title: Text(workHistory[index]['work'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Hours: ${workHistory[index]['hours']}',
                      ),
                      trailing: Text(
                        DateTime.parse(workHistory[index]['timestamp'])
                            .toString()
                            .substring(0, 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => clearAllWorkHistory(),
              child: const Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }
}
