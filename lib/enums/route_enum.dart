/// 音频路由枚举
enum RouteEnum {
  // 扬声器
  Speaker,
  // 听筒
  Earpiece,
}

class RouteTool {
  /// 转换为常量类型
  /// [value] 枚举
  /// [Return] 转换结果
  static int toInt(RouteEnum value) => value.index;

  /// 根据Int类型值获得枚举
  /// [index] Int常量
  /// [Return] 枚举对象
  static RouteEnum getByInt(int index) => RouteEnum.values[index];
}
