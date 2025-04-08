import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:iot_project/ui/screens/devices_screen.dart';
import 'package:iot_project/ui/screens/scene_screen.dart';
import 'package:iot_project/ui/screens/user_info_screen.dart';
import 'package:iot_project/utils/consts.dart';
import 'package:iot_project/utils/mqtt_client.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePageScreen> {
  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 0);
  late final MqttService client;

  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  int maxCount = 5;
  @override
  void initState() {
    client = MqttService(
        broker: baseApiUrl,
        clientId: "sadasdas",
        onConnected: () {},
        onDisconnected: () {});
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// widget list
    List<Widget> bottomBarPages = [
      DevicesScreen(),
      const SceneScreen(),
      InfoScreen(),
    ];
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              /// Provide NotchBottomBarController
              notchBottomBarController: _controller,
              color: Theme.of(context).colorScheme.primary,
              showBottomRadius: false,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: 16,
              kBottomRadius: 0.0,

              removeMargins: true,
              bottomBarWidth: 500,
              showShadow: false,
              durationInMilliSeconds: 300,
              itemLabelStyle: const TextStyle(fontSize: 10),
              elevation: 10,
              bottomBarItems: [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.home_filled,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  activeItem: Icon(
                    Icons.home_filled,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  itemLabel: 'Home',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  activeItem: Icon(
                    Icons.map_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  itemLabel: 'Scene',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  activeItem: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  itemLabel: 'Me',
                ),
              ],
              onTap: (index) {
                // log('current selected index $index');
                _pageController.jumpToPage(index);
              },
              kIconSize: 24.0,
            )
          : null,
    );
  }
}
