import 'package:flutter/material.dart';
import 'package:guardians_app/utils/text_styles.dart';

import '../utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List _notifications = [
  {
  "notification_id": 1,
  "notifier_id": 101,
  "notification_type_id": 1,
  "notification_type": "SOS",
  "message": "Emergency! Immediate help needed!",
  "is_read": false,
  "created_at" : 9 ,
  "notifier": {"name": "Tirthraj Mahajan", "phone": "78899799979"}
},
    {
      "notification_id": 1,
      "notifier_id": 101,
      "notification_type_id": 1,
      "notification_type": "Travel Alert",
      "message": "Emergency! Immediate help needed!",
      "is_read": false,
      "created_at" : 9 ,
      "notifier": {"name": "Tirthraj Mahajan", "phone": "78899799979"}
    },
    {
      "notification_id": 1,
      "notifier_id": 101,
      "notification_type_id": 1,
      "notification_type": "Adaptive Alert",
      "message": "Emergency! Immediate help needed!",
      "is_read": false,
      "created_at" : 9 ,
      "notifier": {"name": "Tirthraj Mahajan", "phone": "78899799979"}
    },
    {
      "notification_id": 1,
      "notifier_id": 101,
      "notification_type_id": 1,
      "notification_type": "General",
      "message": "Emergency! Immediate help needed!",
      "is_read": false,
      "created_at" : 9 ,
      "notifier": {"name": "Tirthraj Mahajan", "phone": "78899799979"}
    },
  ];

  String _selectedFilter = "All";
  final List<String> _filters = ["All", "SOS", "Travel Alert", "Adaptive Alert", "General"];

  List _getFilteredNotifications() {
    if (_selectedFilter == "All") {
      return _notifications;
    }
    return _notifications.where((n) => n["notification_type"] == _selectedFilter).toList();
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(filter, style: TextStyle(color: Colors.white)),
                selected: _selectedFilter == filter,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor: Colors.blueAccent,
                backgroundColor: Colors.grey.shade800,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationContainer(Map<String, dynamic> notification) {
    switch (notification["notification_type"]) {
      case "SOS":
        return SOSNotification(
          message: notification["message"],
          sender: notification["notifier"]["name"],
          phone: notification["notifier"]["phone"],
        );
      case "Travel Alert":
        return TravelAlertNotification(
          message: notification["message"],
          sender: notification["notifier"]["name"],
          phone: notification["notifier"]["phone"],
        );
      case "Adaptive Alert":
        return AdaptiveAlertNotification(
          message: notification["message"],
          sender: notification["notifier"]["name"],
          phone: notification["notifier"]["phone"],
        );
      case "General":
        return GeneralNotification(
          message: notification["message"],
          sender: notification["notifier"]["name"],
          phone: notification["notifier"]["phone"],
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: Text("Notifications", style: AppTextStyles.bold),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          _buildFilterChips(),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
                child: ListView.builder(
                  itemCount: _getFilteredNotifications().length,
                  itemBuilder: (context, index) {
                    return _buildNotificationContainer(_getFilteredNotifications()[index]);
                  },
                ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationContainer extends StatelessWidget {
  final String message;
  final String sender;
  final String phone;
  final Color color;
  final String imagePath;

  const NotificationContainer({
    super.key,
    required this.message,
    required this.sender,
    required this.phone,
    required this.color,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.network(imagePath, width: 50, height: 50),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "From: $sender ($phone)",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SOSNotification extends StatelessWidget {
  final String message;
  final String sender;
  final String phone;

  const SOSNotification(
      {super.key,
      required this.message,
      required this.sender,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return NotificationContainer(
      message: message,
      sender: sender,
      phone: phone,
      color: Colors.red.shade700,
      imagePath: 'https://cdn-icons-png.flaticon.com/512/2858/2858029.png',
    );
  }
}

class TravelAlertNotification extends StatelessWidget {
  final String message;
  final String sender;
  final String phone;

  const TravelAlertNotification(
      {super.key,
      required this.message,
      required this.sender,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return NotificationContainer(
      message: message,
      sender: sender,
      phone: phone,
      color: Colors.orange.shade600,
      imagePath:
          'https://static.vecteezy.com/system/resources/previews/015/153/901/non_2x/car-travel-icon-color-outline-vector.jpg',
    );
  }
}

class AdaptiveAlertNotification extends StatelessWidget {
  final String message;
  final String sender;
  final String phone;

  const AdaptiveAlertNotification(
      {super.key,
      required this.message,
      required this.sender,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return NotificationContainer(
      message: message,
      sender: sender,
      phone: phone,
      color: Colors.cyan.shade600,
      imagePath:
          'https://static.vecteezy.com/system/resources/previews/031/606/756/non_2x/color-icon-for-regions-vector.jpg',
    );
  }
}

class GeneralNotification extends StatelessWidget {
  final String message;
  final String sender;
  final String phone;

  const GeneralNotification(
      {super.key,
      required this.message,
      required this.sender,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return NotificationContainer(
      message: message,
      sender: sender,
      phone: phone,
      color: Colors.blue.shade400,
      imagePath:
          'https://cdn-icons-png.freepik.com/256/3602/3602175.png?semt=ais_hybrid',
    );
  }
}
