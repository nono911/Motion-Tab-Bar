library motiontabbar;

class MotionTabBarController {

  MotionTabBarController();

  set index(int index) {
    _changeIndex!(index);
  }


  Function(int)? _changeIndex;
  set onTabChange(Function(int)? fx) {
    _changeIndex= fx;
  }

}