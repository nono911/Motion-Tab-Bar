import 'package:flutter/material.dart';

const double ICON_OFF = -1;
const double ICON_ON = 0;
const double TEXT_OFF = 3;
const double TEXT_ON = 1;
const double ALPHA_OFF = 0;
const double ALPHA_ON = 1;
const int ANIM_DURATION = 300;

class MotionTabItem extends StatefulWidget {
  final String? label;
  final bool labelAlwaysVisible;
  final bool selected;
  final TextStyle textStyle;
  final TextStyle? textSelectedStyle;
  final Function callbackFunction;
  final Widget? badge;
  final Widget? tabIconWidget;
  final IconData? tabIconData;
  final Color? tabIconColor;
  final double? tabIconSize;

  MotionTabItem({
    required this.label,
    required this.selected,
    required this.textStyle,
    this.textSelectedStyle,
    required this.callbackFunction,
    this.labelAlwaysVisible = false,
    this.badge,
    this.tabIconWidget,
    this.tabIconData,
    this.tabIconColor,
    this.tabIconSize = 24,
  });

  @override
  _MotionTabItemState createState() => _MotionTabItemState();
}

class _MotionTabItemState extends State<MotionTabItem> {
  double iconYAlign = ICON_ON;
  double textYAlign = TEXT_OFF;
  double iconAlpha = ALPHA_ON;

  @override
  void initState() {
    super.initState();
    _setIconTextAlpha();
  }

  @override
  void didUpdateWidget(MotionTabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setIconTextAlpha();
  }

  _setIconTextAlpha() {
    setState(() {
      iconAlpha = (widget.selected) ? ALPHA_OFF : ALPHA_ON;
      iconYAlign = (widget.selected) ? ICON_OFF : ICON_ON;
      textYAlign = (widget.selected) ? TEXT_ON : TEXT_OFF;
      if (widget.labelAlwaysVisible) {
        iconYAlign = iconYAlign - 1;
        textYAlign = TEXT_ON + 0.3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              alignment: Alignment(0, textYAlign),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (widget.labelAlwaysVisible || widget.selected)
                    ? Text(
                        widget.label!,
                        style: widget.selected
                            ? (widget.textSelectedStyle ?? widget.textStyle)
                            : widget.textStyle,
                        softWrap: false,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      )
                    : Text(''),
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () => widget.callbackFunction(),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: AnimatedAlign(
                duration: Duration(milliseconds: ANIM_DURATION),
                curve: Curves.easeIn,
                alignment: Alignment(0, iconYAlign),
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: ANIM_DURATION),
                  opacity: iconAlpha,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      widget.tabIconWidget != null
                          ? widget.tabIconWidget!
                          : _generateDefaultIconButtonWidget(),
                      widget.badge != null
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: widget.badge!,
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _generateDefaultIconButtonWidget() {
    return IconButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashRadius: 0.0,
      padding: EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 0),
      alignment: Alignment(0, 0),
      icon: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Icon(
          widget.tabIconData,
          color: widget.tabIconColor,
          size: widget.tabIconSize,
        ),
      ),
      onPressed: () => widget.callbackFunction(),
    );
  }
}
