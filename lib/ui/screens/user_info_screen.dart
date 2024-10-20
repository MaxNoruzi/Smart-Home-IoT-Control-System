import 'package:flutter/material.dart';
import 'package:iot_project/utils/utils.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({
    Key? key,
  }) : super(key: key);
  void showLogoutConfirmationDialog(
      {required BuildContext context, required Function logoutFunction}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        title: Text('Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 16.0),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 16.0),
            ),
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 16.0),
            ),
            child: Text('Logout'),
            onPressed: () {
              logoutFunction();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show User Name
            ListTile(
              title: Text('User Name'),
              subtitle: Text(Utils.username),
              leading: Icon(Icons.person),
            ),
            Divider(),

            // Option for changing language
            ListTile(
              title: Text('Change Language'),
              leading: Icon(Icons.language),
              onTap: () {},
            ),
            Divider(),

            // Logout option
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.exit_to_app),
              onTap: () {
                showLogoutConfirmationDialog(
                    context: context,
                    logoutFunction: () => Utils.logout(context: context));
                // Utils.logout(context: context);
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
