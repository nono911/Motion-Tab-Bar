library motiontabbar;

import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'motion-tab-item.dart';

typedef MotionTabBuilder = Widget Function();

class MotionTabBar extends StatefulWidget {
  final Color? tabIconColor,
      tabIconSelectedColor,
      tabSelectedColor,
      tabBarColor;
  final double? tabIconSize, tabIconSelectedSize, tabBarHeight, tabSize;
  final TextStyle? textStyle;
  final Function? onTabItemSelected;
  final String initialSelectedTab;

  final List<String?> labels;
  final List<IconData>? icons;
  final List<Widget>? iconWidgets;
  final bool useSafeArea;
  final MotionTabBarController? controller;
  final bool labelAlwaysVisible;

  // badge
  final List<Widget?>? badges;

  MotionTabBar({
    this.textStyle,
    this.tabIconColor = Colors.black,
    this.tabIconSize = 24,
    this.tabIconSelectedColor = Colors.white,
    this.tabIconSelectedSize = 24,
    this.tabSelectedColor = Colors.black,
    this.tabBarColor = Colors.white,
    this.tabBarHeight = 65,
    this.tabSize = 60,
    this.onTabItemSelected,
    required this.initialSelectedTab,
    required this.labels,
    this.icons,
    this.iconWidgets,
    this.useSafeArea = true,
    this.badges,
    this.controller,
    this.labelAlwaysVisible = false,
  })  : assert(labels.contains(initialSelectedTab)),
        assert((icons != null && icons.length == labels.length) ||
            (iconWidgets != null && iconWidgets.length == labels.length)),
        assert((badges != null && badges.length > 0)
            ? badges.length == labels.length
            : true);

  @override
  _MotionTabBarState createState() => _MotionTabBarState();
}

class _MotionTabBarState extends State<MotionTabBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Tween<double> _positionTween;
  late Animation<double> _positionAnimation;

  late AnimationController _fadeOutController;
  late Animation<double> _fadeFabOutAnimation;
  late Animation<double> _fadeFabInAnimation;

  late List<String?> labels;
  Map<String?, IconData>? icons;
  Map<String?, Widget>? iconWidgets;

  get tabAmount => iconWidgets != null && iconWidgets!.keys.length > 0
      ? iconWidgets!.keys.length
      : icons?.keys.length;
  get index => labels.indexOf(selectedTab);
  get position {
    double pace = 2 / (labels.length - 1);
    return (pace * index) - 1;
  }

  double fabIconAlpha = 1;
  IconData? activeIcon;
  Widget? activeIconWidget;
  String? selectedTab;

  List<Widget>? badges;
  Widget? activeBadge;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      widget.controller!.onTabChange = (index) {
        setState(() {
          activeIcon = widget.icons?[index];
          activeIconWidget = widget.iconWidgets?[index];
          selectedTab = widget.labels[index];
        });
        _initAnimationAndStart(_positionAnimation.value, position);
      };
    }

    labels = widget.labels;
    selectedTab = widget.initialSelectedTab;

    if (widget.icons != null && widget.icons!.length > 0) {
      icons = Map.fromIterable(
        labels,
        key: (label) => label,
        value: (label) => widget.icons![labels.indexOf(label)],
      );
      activeIcon = icons![selectedTab];
    }

    if (widget.iconWidgets != null && widget.iconWidgets!.length > 0) {
      iconWidgets = Map.fromIterable(
        labels,
        key: (label) => label,
        value: (label) => widget.iconWidgets![labels.indexOf(label)],
      );
      activeIconWidget = iconWidgets![selectedTab];
    }

    // init badge text
    int selectedIndex =
        labels.indexWhere((element) => element == widget.initialSelectedTab);
    activeBadge = (widget.badges != null && widget.badges!.length > 0)
        ? widget.badges![selectedIndex]
        : null;

    _animationController = AnimationController(
      duration: Duration(milliseconds: ANIM_DURATION),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: Duration(milliseconds: (ANIM_DURATION ~/ 5)),
      vsync: this,
    );

    _positionTween = Tween<double>(begin: position, end: 1);

    _positionAnimation = _positionTween.animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    _fadeFabOutAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabOutAnimation.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            if (icons != null && icons!.length > 0)
              activeIcon = icons![selectedTab];
            if (iconWidgets != null && iconWidgets!.length > 0)
              activeIconWidget = iconWidgets![selectedTab];

            int selectedIndex =
                labels.indexWhere((element) => element == selectedTab);
            activeBadge = (widget.badges != null && widget.badges!.length > 0)
                ? widget.badges![selectedIndex]
                : null;
          });
        }
      });

    _fadeFabInAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.8, 1, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabInAnimation.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.tabBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        bottom: widget.useSafeArea,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              height: widget.tabBarHeight,
              decoration: BoxDecoration(
                color: widget.tabBarColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: generateTabItems(),
              ),
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Align(
                  heightFactor: 0.4,
                  alignment: Alignment(_positionAnimation.value, 0.1),
                  child: FractionallySizedBox(
                    widthFactor: 1 / tabAmount,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: widget.tabSize! + 30,
                          width: widget.tabSize! + 30,
                          child: ClipRect(
                            clipper: HalfClipper(),
                            child: Container(
                              child: Center(
                                child: Container(
                                  width: widget.tabSize!,
                                  height: widget.tabSize!,
                                  decoration: BoxDecoration(
                                    color: widget.tabBarColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: widget.tabSize! + 15,
                          width: widget.tabSize! + 35,
                          child: CustomPaint(
                              painter: HalfPainter(color: widget.tabBarColor)),
                        ),
                        SizedBox(
                          height: widget.tabSize! * 0.7,
                          width: widget.tabSize! * 0.7,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.tabSelectedColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Opacity(
                                opacity: fabIconAlpha,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    activeIconWidget != null
                                        ? activeIconWidget!
                                        : Icon(
                                            activeIcon,
                                            color: widget.tabIconSelectedColor,
                                            size: widget.tabIconSelectedSize! *
                                                0.8,
                                          ),
                                    activeBadge != null
                                        ? Positioned(
                                            top: 0,
                                            right: 0,
                                            child: activeBadge!,
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateTabItems() {
    return labels.map((tabLabel) {
      // IconData? tabIconData = icons[tabLabel];
      // Widget? tabIconWidget = iconWidgets?[tabLabel];

      int selectedIndex = labels.indexWhere((element) => element == tabLabel);
      Widget? badge = (widget.badges != null && widget.badges!.length > 0)
          ? widget.badges![selectedIndex]
          : null;

      return MotionTabItem(
        selected: selectedTab == tabLabel,
        label: tabLabel,
        labelAlwaysVisible: widget.labelAlwaysVisible,
        textStyle: widget.textStyle ?? TextStyle(color: Colors.black),
        tabIconWidget: iconWidgets?[tabLabel],
        tabIconData: icons?[tabLabel],
        tabIconColor: widget.tabIconColor ?? Colors.black,
        tabIconSize: widget.tabIconSize,
        badge: badge,
        callbackFunction: () {
          setState(() {
            activeIcon = icons?[tabLabel];
            activeIconWidget = iconWidgets?[tabLabel];
            selectedTab = tabLabel;
            widget.onTabItemSelected!(index);
          });
          _initAnimationAndStart(_positionAnimation.value, position);
        },
      );
    }).toList();
  }

  _initAnimationAndStart(double from, double to) {
    _positionTween.begin = from;
    _positionTween.end = to;

    _animationController.reset();
    _fadeOutController.reset();
    _animationController.forward();
    _fadeOutController.forward();
  }
}

class HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height / 2);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class HalfPainter extends CustomPainter {
  final Color? color;
  HalfPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // final Rect beforeRect = Rect.fromLTWH(0, (size.height / 2) - 10, 10, 10);
    // final Rect largeRect = Rect.fromLTWH(10, 0, size.width - 20, 70);
    // final Rect afterRect = Rect.fromLTWH(size.width - 10, (size.height / 2) - 10, 10, 10);

    // final path = Path();

    // path.arcTo(beforeRect, vector.radians(0), vector.radians(90), false);
    // path.lineTo(20, size.height / 2);
    // path.arcTo(largeRect, vector.radians(0), -vector.radians(180), false);
    // path.moveTo(size.width - 10, size.height / 2);
    // path.lineTo(size.width - 10, (size.height / 2) - 10);
    // path.arcTo(afterRect, vector.radians(180), vector.radians(-90), false);

    final double curveSize = 10;
    final double xStartingPos = 0;
    final double yStartingPos = (size.height / 2);
    final double yMaxPos = yStartingPos - curveSize;

    final path = Path();

    path.moveTo(xStartingPos, yStartingPos);
    path.lineTo(size.width - xStartingPos, yStartingPos);
    path.quadraticBezierTo(size.width - (curveSize), yStartingPos,
        size.width - (curveSize + 5), yMaxPos);
    path.lineTo(xStartingPos + (curveSize + 5), yMaxPos);
    path.quadraticBezierTo(
        xStartingPos + (curveSize), yStartingPos, xStartingPos, yStartingPos);

    path.close();

    canvas.drawPath(path, Paint()..color = color ?? Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
