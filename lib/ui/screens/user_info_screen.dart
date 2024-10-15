import 'package:flutter/material.dart';
import 'package:iot_project/utils/utils.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({
    Key? key,
  }) : super(key: key);

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
                Utils.logout(context: context);
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
