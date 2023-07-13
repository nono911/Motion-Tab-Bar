# Motion Tab Bar v2, with null-safety support

[![pub package](https://img.shields.io/pub/v/motion_tab_bar_v2)](https://pub.dev/packages/motion_tab_bar_v2)
[![likes](https://img.shields.io/pub/likes/motion_tab_bar_v2)](https://pub.dev/packages/motion_tab_bar_v2/score)
[![popularity](https://img.shields.io/pub/popularity/motion_tab_bar_v2)](https://pub.dev/packages/motion_tab_bar_v2/score)
[![pub points](https://img.shields.io/pub/points/motion_tab_bar_v2)](https://pub.dev/packages/motion_tab_bar_v2/score)

A beautiful animated widget for your Flutter Tab Bar.


**Preview:**

### > v0.3.0 screenshot

![0.3.x screenshot, example with programmatically change tabs](https://github.com/kimmanwky/Motion-Tab-Bar/blob/master/screenshots/screenshot3.png?raw=true)


### > v0.2.1 screenshot

![0.2.x screenshot](https://github.com/kimmanwky/Motion-Tab-Bar/blob/master/screenshots/screenshot2.png?raw=true)

### v0.1.x animation preview

![MotionTabBar Gif](https://github.com/kimmanwky/Motion-Tab-Bar/blob/master/screenshots/motiontabbar.gif?raw=true)

<br>

## Getting Started

Add the plugin:

```yaml
dependencies:
  motion_tab_bar_v2: ^0.3.0
```

## Basic Usage

### Import package

```dart
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

// optional, only if using provided badge style
import 'package:motion_tab_bar_v2/motion-badge.widget.dart';

// optional, only if using "MotionTabBarController" to programmatically change the tab
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';

```

### Use default TabController:

```dart
  // TabController _tabController;
  MotionTabBarController? _motionTabBarController;

  @override
  void initState() {
    super.initState();
    
    //// Use normal tab controller
    // _tabController = TabController(
    //   initialIndex: 1,
    //   length: 4,
    //   vsync: this,
    // );

    //// use "MotionTabBarController" to replace with "TabController", if you need to programmatically change the tab
    _motionTabBarController = MotionTabBarController(
      initialIndex: 1,
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();

    // _tabController.dispose();
    _motionTabBarController!.dispose();
  }
```

### Add Motion Tab Bar to bottomNavigationbar:

```dart
  bottomNavigationBar: MotionTabBar(
    controller: _motionTabBarController, // ADD THIS if you need to change your tab programmatically
    initialSelectedTab: "Home",
    labels: const ["Dashboard", "Home", "Profile", "Settings"],
    icons: const [Icons.dashboard, Icons.home, Icons.people_alt, Icons.settings],

    // optional badges, length must be same with labels
    badges: [
      // Default Motion Badge Widget
      const MotionBadgeWidget(
        text: '99+',
        textColor: Colors.white, // optional, default to Colors.white
        color: Colors.red, // optional, default to Colors.red
        size: 18, // optional, default to 18
      ),

      // custom badge Widget
      Container(
        color: Colors.black,
        padding: const EdgeInsets.all(2),
        child: const Text(
          '48',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),

      // allow null
      null,

      // Default Motion Badge Widget with indicator only
      const MotionBadgeWidget(
        isIndicator: true,
        color: Colors.red, // optional, default to Colors.red
        size: 5, // optional, default to 5,
        show: true, // true / false
      ),
    ],
    tabSize: 50,
    tabBarHeight: 55,
    textStyle: const TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    tabIconColor: Colors.blue[600],
    tabIconSize: 28.0,
    tabIconSelectedSize: 26.0,
    tabSelectedColor: Colors.blue[900],
    tabIconSelectedColor: Colors.white,
    tabBarColor: const Color(0xFFAFAFAF),
    onTabItemSelected: (int value) {
      setState(() {
        // _tabController!.index = value;
        _motionTabBarController!.index = value;
      });
    },
  ),
```

### add TabBarView to Scaffold body

```dart
  body: TabBarView(
    physics: NeverScrollableScrollPhysics(), // swipe navigation handling is not supported
    // controller: _tabController,
    controller: _motionTabBarController,
    children: <Widget>[
      const Center(
        child: Text("Dashboard"),
      ),
      const Center(
        child: Text("Home"),
      ),
      const Center(
        child: Text("Profile"),
      ),
      const Center(
        child: Text("Settings"),
      ),
    ],
  ),
```


### to change tabs programmatically
```dart
...

ElevatedButton(
  // set MotionTabBarController index to new tab index
  onPressed: () => _motionTabBarController.index = 0,
  child: const Text('Dashboard Page'),
),
ElevatedButton(
  // set MotionTabBarController index to new tab index
  onPressed: () => _motionTabBarController.index = 1,
  child: const Text('Home Page'),
),

...

```
