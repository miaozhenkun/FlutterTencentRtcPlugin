import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tencent_rtc_plugin/entity/audio_effect_finished_entity.dart';
import 'package:tencent_rtc_plugin/entity/audio_frame_entity.dart';
import 'package:tencent_rtc_plugin/entity/audio_route_changed_entity.dart';
import 'package:tencent_rtc_plugin/entity/common_status_entity.dart';
import 'package:tencent_rtc_plugin/entity/custom_message_entity.dart';
import 'package:tencent_rtc_plugin/entity/custom_message_receive_entity.dart';
import 'package:tencent_rtc_plugin/entity/log_entity.dart';
import 'package:tencent_rtc_plugin/entity/network_quality_entity.dart';
import 'package:tencent_rtc_plugin/entity/sei_message_entity.dart';
import 'package:tencent_rtc_plugin/entity/speed_test_entity.dart';
import 'package:tencent_rtc_plugin/entity/statistics_entity.dart';
import 'package:tencent_rtc_plugin/entity/user_available_entity.dart';
import 'package:tencent_rtc_plugin/entity/user_leave_room_entity.dart';
import 'package:tencent_rtc_plugin/entity/user_status_entity.dart';
import 'package:tencent_rtc_plugin/entity/video_frame_entity.dart';
import 'package:tencent_rtc_plugin/entity/voice_volume_entity.dart';
import 'package:tencent_rtc_plugin/enums/debug_view_mode_enum.dart';
import 'package:tencent_rtc_plugin/enums/gsensor_mode_enum.dart';
import 'package:tencent_rtc_plugin/enums/log_level_enum.dart';
import 'package:tencent_rtc_plugin/enums/mirror_type_enum.dart';
import 'package:tencent_rtc_plugin/enums/qos_control_enum.dart';
import 'package:tencent_rtc_plugin/enums/qos_preference_enum.dart';
import 'package:tencent_rtc_plugin/enums/quality_enum.dart';
import 'package:tencent_rtc_plugin/enums/render_mode_enum.dart';
import 'package:tencent_rtc_plugin/enums/role_enum.dart';
import 'package:tencent_rtc_plugin/enums/rotation_enum.dart';
import 'package:tencent_rtc_plugin/enums/route_enum.dart';
import 'package:tencent_rtc_plugin/enums/scene_enum.dart';
import 'package:tencent_rtc_plugin/enums/stream_type_enum.dart';
import 'package:tencent_rtc_plugin/enums/system_volume_type_enum.dart';
import 'package:tencent_rtc_plugin/utils/assets_util.dart';

import 'entity/video_enc_param_entity.dart';
import 'enums/listener_type_enum.dart';

class TencentRtcPlugin {
  static const MethodChannel _channel = const MethodChannel('tencent_rtc_plugin');

  /// 监听器对象
  static TencentRtcPluginListener listener;

  /// 添加消息监听
  static void addListener(ListenerValue func) {
    if (listener == null) {
      listener = TencentRtcPluginListener(_channel);
    }
    listener.addListener(func);
  }

  /// 移除消息监听
  static void removeListener(ListenerValue func) {
    if (listener == null) {
      listener = TencentRtcPluginListener(_channel);
    }
    listener.removeListener(func);
  }

  /// 设置Debug视图
  static showDebugView({@required DebugViewModeEnum mode}) => _channel.invokeMethod('showDebugView', {"mode": DebugViewModeTool.toInt(mode)});

  /// 加入房间(默认开启音频接收)
  /// [appid] appid
  /// [userId] 用户ID
  /// [userSig] 用户签名
  /// [roomId] 房间号
  /// [scene] 应用场景，目前支持视频通话（VideoCall）和在线直播（Live）两种场景。
  /// [role] 角色
  /// [privateMapKey] 房间签名
  static enterRoom({
    @required int appid,
    @required String userId,
    @required String userSig,
    @required int roomId,
    @required SceneEnum scene,
    RoleEnum role,
    String privateMapKey,
  }) {
    _channel.invokeMethod('enterRoom', {
      "appid": appid,
      "userId": userId,
      "userSig": userSig,
      "roomId": roomId,
      "scene": SceneTool.toInt(scene),
      "role": role == null ? null : RoleTool.toInt(role),
      "privateMapKey": privateMapKey,
    });
  }

  /// 离开房间
  static exitRoom() => _channel.invokeMethod('exitRoom');

  /// 切换角色，仅适用于直播场景（TRTC_APP_SCENE_LIVE 和 TRTC_APP_SCENE_VOICE_CHATROOM）。
  /// [role] 目标角色
  static switchRole({@required RoleEnum role}) => _channel.invokeMethod('switchRole', {"role": RoleTool.toInt(role)});

  /// 请求跨房通话（主播 PK）
  /// [param] JSON 字符串连麦参数，roomId 代表目标房间号，userId 代表目标用户 ID。
  static connectOtherRoom({@required String param}) => _channel.invokeMethod('connectOtherRoom', {'param': param});

  /// 退出跨房通话
  static disconnectOtherRoom() => _channel.invokeMethod('disconnectOtherRoom');

  /// 设置音视频数据接收模式，需要在进房前设置才能生效。
  /// [autoRecvAudio] true：自动接收音频数据；false：需要调用 muteRemoteAudio 进行请求或取消。默认值：true。
  /// [autoRecvVideo] true：自动接收视频数据；false：需要调用 startRemoteView/stopRemoteView 进行请求或取消。默认值：true。
  static setDefaultStreamRecvMode({
    @required bool autoRecvAudio,
    @required bool autoRecvVideo,
  }) {
    _channel.invokeMethod('setDefaultStreamRecvMode', {
      "autoRecvAudio": autoRecvAudio,
      "autoRecvVideo": autoRecvVideo,
    });
  }

  /// 开始向腾讯云的直播 CDN 推流
  /// [streamId] 自定义流 Id。
  /// [streamType] 流类型,仅支持 Big 和 Sub
  static startPublishing({
    @required String streamId,
    @required StreamTypeEnum streamType,
  }) {
    _channel.invokeMethod('startPublishing', {
      "streamId": streamId,
      "streamType": StreamTypeTool.toInt(streamType),
    });
  }

  /// 停止向腾讯云的直播 CDN 推流
  static stopPublishing() => _channel.invokeMethod('stopPublishing');

  /// 开始向友商云的直播 CDN 转推
  /// [appid] appid
  /// [bizId] 腾讯云直播 bizid，请在 实时音视频控制台 选择已经创建的应用，单击【帐号信息】，在“直播信息”中获取
  /// [url] 旁路转推的 URL
  static startPublishCDNStream({
    @required String appid,
    @required String bizId,
    @required String url,
  }) {
    _channel.invokeMethod('startPublishCDNStream', {
      "appid": appid,
      "bizId": bizId,
      "url": url,
    });
  }

  /// 停止向非腾讯云地址转推
  static stopPublishCDNStream() => _channel.invokeMethod('stopPublishCDNStream');

  /// 停止本地视频采集
  static stopLocalPreview() => _channel.invokeMethod('stopLocalPreview');

  /// 关闭远程显示
  /// [userId] 用户ID
  static stopRemoteView({@required String userId}) => _channel.invokeMethod('stopRemoteView', {"userId": userId});

  /// 关闭本地的视频。
  /// [mute] 是否关闭
  static muteLocalVideo({@required bool mute}) {
    return _channel.invokeMethod('muteLocalVideo', {
      "mute": mute,
    });
  }

  /// 设置暂停推送本地视频时要推送的图片。
  /// [asset] assets 中的资源，不是本地原生资源!!!
  /// [fps] 推送图片帧率，Android: 最小值为5，最大值为20，默认10。IOS: 最小值为5，最大值为10。
  static setVideoMuteImage({
    String asset,
    int fps: 10,
  }) {
    return _channel.invokeMethod('setVideoMuteImage', {
      "image": asset == null ? null : AssetsUtil.copyAssetToLocal(asset),
      "fps": fps,
    });
  }

  /// 停止显示所有远端视频画面。
  static stopAllRemoteView() => _channel.invokeMethod('stopAllRemoteView');

  /// 暂停接收指定的远端视频流。。
  /// [userId] 用户ID
  /// [mute] 是否停止接收
  static muteRemoteVideoStream({
    @required String userId,
    @required bool mute,
  }) {
    return _channel.invokeMethod('muteRemoteVideoStream', {
      "userId": userId,
      "mute": mute,
    });
  }

  /// 停止接收所有远端视频流
  /// [mute] 是否停止接收
  static muteAllRemoteVideoStreams({@required bool mute}) => _channel.invokeMethod('muteAllRemoteVideoStreams', {"mute": mute});

  /// 设置视频编码相关
  /// [param] 视频编码参数
  static setVideoEncoderParam({
    @required VideoEncParamEntity param,
  }) {
    return _channel.invokeMethod('setVideoEncoderParam', {
      "param": jsonEncode(param),
    });
  }

  /// 设置网络流控相关参数。参考: http://doc.qcloudtrtc.com/group__TRTCCloudDef__android.html#classcom_1_1tencent_1_1trtc_1_1TRTCCloudDef_1_1TRTCNetworkQosParam
  /// [preference] 弱网下是“保清晰”还是“保流畅”。
  /// [controlMode] 视频分辨率（云端控制 - 客户端控制）。
  static setNetworkQosParam({
    @required QosPreferenceEnum preference,
    @required QosControlEnum controlMode,
  }) async {
    return _channel.invokeMethod('setNetworkQosParam', {
      "preference": QosPreferenceTool.toInt(preference),
      "controlMode": QosControlTool.toInt(controlMode),
    });
  }

  /// 设置本地图像的渲染模式
  static setLocalViewFillMode({@required RenderModeEnum mode}) => _channel.invokeMethod('setLocalViewFillMode', {"mode": RenderModeTool.toInt(mode)});

  /// 设置远程视频填充模式
  /// [userId] 用户ID
  /// [mode] 模式
  static setRemoteViewFillMode({
    @required String userId,
    @required RenderModeEnum mode,
  }) {
    return _channel.invokeMethod('setRemoteViewFillMode', {
      "userId": userId,
      "mode": RenderModeTool.toInt(mode),
    });
  }

  /// 设置本地图像的顺时针旋转角度。
  /// [rotation] 角度
  static setLocalViewRotation({
    @required RotationEnum rotation,
  }) {
    return _channel.invokeMethod('setLocalViewRotation', {
      "rotation": RotationTool.toInt(rotation),
    });
  }

  /// 设置远端图像的顺时针旋转角度。
  /// [userId] 用户ID
  /// [rotation] 角度
  static setRemoteViewRotation({
    @required String userId,
    @required RotationEnum rotation,
  }) {
    return _channel.invokeMethod('setRemoteViewRotation', {
      "userId": userId,
      "rotation": RotationTool.toInt(rotation),
    });
  }

  /// 设置视频编码输出的（也就是远端用户观看到的，以及服务器录制下来的）画面方向
  /// [rotation] 旋转角度，目前仅支持 Rotation_0 和 Rotation_180
  static setVideoEncoderRotation({
    @required RotationEnum rotation,
  }) {
    return _channel.invokeMethod('setVideoEncoderRotation', {
      "rotation": RotationTool.toInt(rotation),
    });
  }

  /// 设置本地摄像头预览画面的镜像模式。
  /// [mirrorType] 镜像模式
  static setLocalViewMirror({
    @required MirrorTypeEnum mirrorType,
  }) {
    return _channel.invokeMethod('setLocalViewMirror', {
      "mirrorType": MirrorTypeTool.toInt(mirrorType),
    });
  }

  /// 设置编码器输出的画面镜像模式。
  /// [mirror] true：镜像；false：不镜像；默认值：false。
  static setVideoEncoderMirror({
    @required bool mirror,
  }) {
    return _channel.invokeMethod('setVideoEncoderMirror', {
      "mirror": mirror,
    });
  }

  /// 设置重力感应的适应模式。
  /// [mode] 重力感应模式
  static setGSensorMode({
    @required GsensorModeEnum mode,
  }) {
    return _channel.invokeMethod('setGSensorMode', {
      "mode": GsensorModeTool.toInt(mode),
    });
  }

  /// 开启大小画面双路编码模式。
  /// [enable] 是否开启小画面编码
  /// [smallVideoEncParam] 小流的视频参数。
  static Future<int> enableEncSmallVideoStream({
    @required bool enable,
    @required VideoEncParamEntity smallVideoEncParam,
  }) {
    return _channel.invokeMethod('enableEncSmallVideoStream', {
      "enable": enable,
      "smallVideoEncParam": jsonEncode(smallVideoEncParam),
    });
  }

  /// 选定观看指定 uid 的大画面或小画面。
  /// [userId] 用户ID
  /// [streamType] 流类型
  static setRemoteVideoStreamType({
    @required String userId,
    @required StreamTypeEnum streamType,
  }) {
    return _channel.invokeMethod('setRemoteVideoStreamType', {
      "userId": userId,
      "streamType": StreamTypeTool.toInt(streamType),
    });
  }

  /// 设定观看方优先选择的视频质量。
  /// [streamType] 流类型
  static setPriorRemoteVideoStreamType({
    @required StreamTypeEnum streamType,
  }) {
    return _channel.invokeMethod('setPriorRemoteVideoStreamType', {
      "streamType": StreamTypeTool.toInt(streamType),
    });
  }

  /// 设置音频质量 主播端的音质越高，观众端的听感越好，但传输所依赖的带宽也就越高，在带宽有限的场景下也更容易出现卡顿。
  /// [quality] 质量
  static setAudioQuality({
    @required QualityEnum quality,
  }) {
    return _channel.invokeMethod('setAudioQuality', {
      "quality": QualityTool.toInt(quality),
    });
  }

  /// 开启本地音频采集
  static startLocalAudio() {
    return _channel.invokeMethod('startLocalAudio');
  }

  /// 关闭本地音频采集
  static stopLocalAudio() {
    return _channel.invokeMethod('stopLocalAudio');
  }

  /// 静音本地的音频。
  /// [mute] true：屏蔽；false：开启，默认值：false。
  static muteLocalAudio({
    @required bool mute,
  }) {
    return _channel.invokeMethod('muteLocalAudio', {
      "mute": mute,
    });
  }

  /// 设置音频路由。
  /// [route] 音频路由，即声音由哪里输出（扬声器、听筒)
  static setAudioRoute({@required RouteEnum route}) {
    return _channel.invokeMethod('setAudioRoute', {
      "route": RouteTool.toInt(route),
    });
  }

  /// 静音/取消静音
  /// [userId] 用户ID
  /// [mute] 是否静音
  static muteRemoteAudio({
    @required String userId,
    @required bool mute,
  }) {
    return _channel.invokeMethod('muteRemoteAudio', {
      "userId": userId,
      "mute": mute,
    });
  }

  /// 静音/取消静音 所有用户
  /// [mute] 是否静音
  static muteAllRemoteAudio({@required bool mute}) => _channel.invokeMethod('muteAllRemoteAudio', {"mute": mute});

  /// 设置 SDK 采集音量。
  /// [volume] 音量大小，取值: 0-100
  static setAudioCaptureVolume({@required int volume}) => _channel.invokeMethod('setAudioCaptureVolume', {"volume": volume});

  /// 获取 SDK 采集音量
  static Future<int> getAudioCaptureVolume() => _channel.invokeMethod('getAudioCaptureVolume');

  /// 设置 SDK 播放音量。
  /// [volume] 音量大小，取值: 0-100
  static setAudioPlayoutVolume({@required int volume}) => _channel.invokeMethod('setAudioPlayoutVolume', {"volume": volume});

  /// 获取 SDK 播放音量
  static Future<int> getAudioPlayoutVolume() => _channel.invokeMethod('getAudioPlayoutVolume');

  /// 启用音量大小提示。
  /// [intervalMs] 决定了 onUserVoiceVolume 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；详细的回调规则请参考 onUserVoiceVolume 的注释说明。
  static enableAudioVolumeEvaluation({@required int intervalMs}) => _channel.invokeMethod('enableAudioVolumeEvaluation', {"intervalMs": intervalMs});

  /// 开始录音。
  /// [filePath] 文件路径（必填），录音的文件地址，由用户自行指定，请确保 App 里指定的目录存在且可写。
  static startAudioRecording({@required String filePath}) => _channel.invokeMethod('startAudioRecording', {"filePath": filePath});

  /// 停止录音。
  static stopAudioRecording() => _channel.invokeMethod('stopAudioRecording');

  /// 设置通话时使用的系统音量类型。
  /// [type] 系统音量类型
  static setSystemVolumeType({@required SystemVolumeTypeEnum type}) => _channel.invokeMethod('setSystemVolumeType', {"type": SystemVolumeTypeTool.toInt(type)});

  /// 开启耳返。
  /// [enable] 是否启用
  static enableAudioEarMonitoring({@required bool enable}) => _channel.invokeMethod('enableAudioEarMonitoring', {"enable": enable});

  /// 切换摄像头。
  static switchCamera() => _channel.invokeMethod('switchCamera');

  /// 查询当前摄像头是否支持缩放
  static Future<bool> isCameraZoomSupported() => _channel.invokeMethod('isCameraZoomSupported');

  /// 设置摄像头缩放因子（焦距）。
  /// [distance] 取值范围为1 - 5，数值越大，焦距越远。
  static setZoom({@required int distance}) => _channel.invokeMethod('setZoom', {"distance": distance});

  /// 查询是否支持开关闪光灯（手电筒模式）。
  static Future<bool> isCameraTorchSupported() => _channel.invokeMethod('isCameraTorchSupported');

  /// 开关闪光灯。
  /// [enable] 是否开启
  static enableTorch({@required bool enable}) => _channel.invokeMethod('enableTorch', {"enable": enable});

  /// 查询是否支持设置焦点。
  static Future<bool> isCameraFocusPositionInPreviewSupported() => _channel.invokeMethod('isCameraFocusPositionInPreviewSupported');

  /// 设置摄像头焦点。
  static setFocusPosition({
    @required int x,
    @required int y,
  }) async {
    return _channel.invokeMethod('setFocusPosition', {
      "x": x,
      "y": y,
    });
  }

  /// 查询是否支持自动识别人脸位置。
  static Future<bool> isCameraAutoFocusFaceModeSupported() => _channel.invokeMethod('isCameraAutoFocusFaceModeSupported');

  /// 添加水印
  /// [asset] assets 中的资源，不是本地原生资源!!!
  /// [streamType] 流类型
  /// [x] 归一化水印位置的 X 轴坐标，取值[0,1]
  /// [y] 归一化水印位置的 Y 轴坐标，取值[0,1]
  /// [width] 归一化水印宽度，取值[0,1]
  /// [height] 归一化水印宽度，取值[0,1]，仅IOS有效
  static setWatermark({
    @required String asset,
    @required StreamTypeEnum streamType,
    @required double x,
    @required double y,
    @required double width,
    double height: 0.5,
  }) async {
    return _channel.invokeMethod('setWatermark', {
      "image": AssetsUtil.copyAssetToLocal(asset),
      "streamType": StreamTypeTool.toInt(streamType),
      "x": x,
      "y": y,
      "width": width,
      "height": height,
    });
  }

  /// 停止屏幕采集。
  static stopScreenCapture() => _channel.invokeMethod('stopScreenCapture');

  /// 暂停屏幕分享。
  static pauseScreenCapture() => _channel.invokeMethod('pauseScreenCapture');

  /// 恢复屏幕分享。
  static resumeScreenCapture() => _channel.invokeMethod('resumeScreenCapture');

  /// 关闭远端辅流显示
  /// [userId] 用户ID
  static stopRemoteSubStreamView({@required String userId}) => _channel.invokeMethod("stopRemoteSubStreamView", {"userId": userId});

  /// 设置屏幕分享画面的显示模式。
  /// [userId] 用户ID
  /// [mode] 显示模式
  static setRemoteSubStreamViewFillMode({
    @required String userId,
    @required RenderModeEnum mode,
  }) {
    return _channel.invokeMethod("setRemoteSubStreamViewFillMode", {
      "userId": userId,
      "mode": RenderModeTool.toInt(mode),
    });
  }

  /// 设置屏幕分享画面的顺时针旋转角度。
  /// [userId] 用户ID
  /// [rotation] 旋转角度
  static setRemoteSubStreamViewRotation({
    @required String userId,
    @required RotationEnum rotation,
  }) {
    return _channel.invokeMethod("setRemoteSubStreamViewRotation", {
      "userId": userId,
      "rotation": RotationTool.toInt(rotation),
    });
  }

  /// 发送自定义消息给房间内所有用户。
  /// [cmdID] 消息 ID，取值范围为1 - 10
  /// [data] 	待发送的消息，最大支持1KB（1000字节）的数据大小
  /// [reliable] 	是否可靠发送，可靠发送的代价是会引入一定的延时，因为接收端要暂存一段时间的数据来等待重传
  /// [ordered] 	是否要求有序，即是否要求接收端接收的数据顺序和发送端发送的顺序一致，这会带来一定的接收延时，因为在接收端需要暂存并排序这些消息。
  static sendCustomCmdMsg({
    @required int cmdID,
    @required Uint8List data,
    @required bool reliable,
    @required bool ordered,
  }) {
    return _channel.invokeMethod("sendCustomCmdMsg", {
      "cmdID": cmdID,
      "data": data,
      "reliable": reliable,
      "ordered": ordered,
    });
  }

  /// 将小数据量的自定义数据嵌入视频帧中
  /// [data] 		待发送的数据，最大支持1kb（1000字节）的数据大小
  /// [repeatCount] 	发送数据次数
  static sendSEIMsg({
    @required String data,
    @required int repeatCount,
  }) {
    return _channel.invokeMethod("sendSEIMsg", {
      "data": data,
      "repeatCount": repeatCount,
    });
  }

  /// 开始进行网络测速（视频通话期间请勿测试，以免影响通话质量）
  /// [appid] appid
  /// [userId] 用户ID
  /// [userSig] 用户签名
  static startSpeedTest({
    @required int appid,
    @required String userId,
    @required String userSig,
  }) {
    return _channel.invokeMethod("startSpeedTest", {
      "appid": appid,
      "userId": userId,
      "userSig": userSig,
    });
  }

  /// 停止服务器测速
  static stopSpeedTest() => _channel.invokeMethod("stopSpeedTest");

  /// 获得SDK版本
  static Future<String> getSDKVersion() => _channel.invokeMethod("getSDKVersion");

  /// 设置日志输出级别
  /// [level] 日志级别
  static setLogLevel({@required LogLevelEnum level}) => _channel.invokeMethod("setLogLevel", {"level": LogLevelTool.toInt(level)});

  /// 设置启用控制台打印
  /// [enabled] 是否启用
  static setConsoleEnabled({@required bool enabled}) => _channel.invokeMethod('setConsoleEnabled', {"enabled": enabled});

  /// 启用或禁用 Log 的本地压缩。
  /// [enabled] 是否启用
  static setLogCompressEnabled({@required bool enabled}) => _channel.invokeMethod('setLogCompressEnabled', {"enabled": enabled});

  /// 修改日志保存路径。
  /// [path] 保存路径
  static setLogDirPath({@required String path}) => _channel.invokeMethod('setLogDirPath', {"path": path});

  /// 设置仪表盘的边距。
  /// [userId] 用户ID
  static setDebugViewMargin({
    @required String userId,
    @required double left,
    @required double right,
    @required double top,
    @required double bottom,
  }) {
    return _channel.invokeMethod('setDebugViewMargin', {
      "userId": userId,
      "left": left,
      "right": right,
      "top": top,
      "bottom": bottom,
    });
  }

  /// 生成用户签名。
  /// **********
  /// TODO【警告，该接口仅供调试，生产环境下请通过服务器生成签名】
  /// **********
  /// [appid] appid
  /// [secretKey] 密钥
  /// [userId] 自定义用户ID
  static Future<String> genUserSig({
    @required int appid,
    @required String secretKey,
    @required String userId,
  }) {
    return _channel.invokeMethod('genUserSig', {
      "appid": appid,
      "secretKey": secretKey,
      "userId": userId,
    });
  }
}

/// 监听器对象
class TencentRtcPluginListener {
  /// 监听器列表
  static Set<ListenerValue> listeners = Set();

  TencentRtcPluginListener(MethodChannel channel) {
    // 绑定监听器
    channel.setMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'onListener':
          // 解析参数
          Map<String, dynamic> arguments = methodCall.arguments is String ? jsonDecode(methodCall.arguments) : methodCall.arguments.cast<String, dynamic>();

          // 获得原始类型和参数
          String typeStr = arguments['type'];
          var params = arguments['params'];

          // 封装回调类型和参数
          ListenerTypeEnum type;

          // 初始化类型
          for (var item in ListenerTypeEnum.values) {
            if (item.toString().replaceFirst("ListenerTypeEnum.", "") == typeStr) {
              type = item;
              break;
            }
          }

          // 没有找到类型就返回
          if (type == null) {
            throw MissingPluginException();
          }

          // 根据类型进行解析
          try {
            switch (type) {
              case ListenerTypeEnum.SdkError:
              case ListenerTypeEnum.Warning:
              case ListenerTypeEnum.SwitchRole:
              case ListenerTypeEnum.DisConnectOtherRoom:
              case ListenerTypeEnum.StartPublishing:
              case ListenerTypeEnum.StopPublishing:
              case ListenerTypeEnum.StartPublishCDNStream:
              case ListenerTypeEnum.StopPublishCDNStream:
              case ListenerTypeEnum.SetMixTranscodingConfig:
                params = CommonStatusEntity.fromJson(params);
                break;
              case ListenerTypeEnum.ConnectOtherRoom:
                params = UserStatusEntity.fromJson(params);
                break;
              case ListenerTypeEnum.RemoteUserLeaveRoom:
                params = UserLeaveRoomEntity.fromJson(params);
                break;
              case ListenerTypeEnum.UserVideoAvailable:
              case ListenerTypeEnum.UserSubStreamAvailable:
              case ListenerTypeEnum.UserAudioAvailable:
                params = UserAvailableEntity.fromJson(params);
                break;
              case ListenerTypeEnum.FirstVideoFrame:
                params = VideoFrameEntity.fromJson(params);
                break;
              case ListenerTypeEnum.EnterRoom:
                params = params is int ? params : int.parse(params);
                break;
              case ListenerTypeEnum.ExitRoom:
              case ListenerTypeEnum.RemoteUserEnterRoom:
              case ListenerTypeEnum.FirstAudioFrame:
              case ListenerTypeEnum.SendFirstLocalAudioFrame:
              case ListenerTypeEnum.ConnectionLost:
              case ListenerTypeEnum.TryToReconnect:
              case ListenerTypeEnum.ConnectionRecovery:
              case ListenerTypeEnum.CameraDidReady:
              case ListenerTypeEnum.MicDidReady:
              case ListenerTypeEnum.ScreenCaptureStarted:
              case ListenerTypeEnum.ScreenCapturePaused:
              case ListenerTypeEnum.ScreenCaptureResumed:
              case ListenerTypeEnum.ScreenCaptureStopped:
                break;
              case ListenerTypeEnum.SendFirstLocalVideoFrame:
                params = StreamTypeTool.getByInt(params);
                break;
              case ListenerTypeEnum.NetworkQuality:
                params = NetworkQualityEntity.fromJson(params);
                break;
              case ListenerTypeEnum.Statistics:
                params = StatisticsEntity.fromJson(params);
                break;
              case ListenerTypeEnum.SpeedTest:
                params = SpeedTestEntity.fromJson(params);
                break;
              case ListenerTypeEnum.AudioRouteChanged:
                params = AudioRouteChangedEntity.fromJson(params);
                break;
              case ListenerTypeEnum.UserVoiceVolume:
                params = VoiceVolumeEntity.fromJson(params);
                break;
              case ListenerTypeEnum.RecvCustomCmdMsg:
                params = CustomMessageReceiveEntity.fromJson(params);
                break;
              case ListenerTypeEnum.MissCustomCmdMsg:
                params = CustomMessageEntity.fromJson(params);
                break;
              case ListenerTypeEnum.RecvSEIMsg:
                params = SeiMessageEntity.fromJson(params);
                break;
              case ListenerTypeEnum.AudioEffectFinished:
                params = AudioEffectFinishedEntity.fromJson(params);
                break;
              case ListenerTypeEnum.CapturedRawAudioFrame:
              case ListenerTypeEnum.LocalProcessedAudioFrame:
              case ListenerTypeEnum.RemoteUserAudioFrame:
              case ListenerTypeEnum.MixedPlayAudioFrame:
                params = AudioFrameEntity.fromJson(params);
                break;
              case ListenerTypeEnum.Log:
                params = LogEntity.fromJson(params);
                break;
            }
          } catch (err) {
            print("$type 监听器错误:$err，请联系开发者进行处理！Github Issues: https://github.com/JiangJuHong/FlutterTencentRtcPlugin/issues");
          }

          // 回调触发
          for (var item in listeners) {
            item(type, params);
          }

          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  /// 添加消息监听
  void addListener(ListenerValue func) {
    listeners.add(func);
  }

  /// 移除消息监听
  void removeListener(ListenerValue func) {
    listeners.remove(func);
  }
}

/// 监听器值模型
typedef ListenerValue<P> = void Function(ListenerTypeEnum type, P params);
