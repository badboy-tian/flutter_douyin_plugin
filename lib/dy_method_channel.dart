import 'package:dy/model/result_model.dart';
import 'package:dy/utils/token/token_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'callback/dy_callback.dart';
import 'conf/dyConf.dart';
import 'dy_platform_interface.dart';

/// An implementation of [DyPlatform] that uses method channels.
class MethodChannelDy extends DyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dy');

  DyCallBackListener? _callBackListener;

  MethodChannelDy() {
    methodChannel.setMethodCallHandler((call) async {
      debugPrint("${call.method}---${call.arguments}");
      String method = call.method;
      switch (method) {
        case "getAccessToken":
          dynamic arguments = call.arguments;
          if (arguments != null) {
            debugPrint("arguments is $arguments");
            try {
              var code = arguments["code"];
              var result = arguments["result"];
              var errorMessage = arguments["errorMessage"];
              //debugPrint("_callBackListener == null: ${_callBackListener == null}");
              if (_callBackListener != null) {
                _callBackListener!("getAuthCode", arguments);
              }
            } on Exception catch (e) {
              debugPrint("error is $e");
            }
          }
          return Future.value(true);
        case "getSharePageResult":
          dynamic arguments = call.arguments;
          _callBackListener?.call("getSharePageResult", arguments);
          return Future.value(true);
        default:
          return Future.value(true);
      }
    });
  }

  @override
  void addDyCallbackListener(DyCallBackListener callBackListener) {
    _callBackListener = callBackListener;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<dynamic?> loginInWithDouyin(String scope) async {
    final result = await methodChannel.invokeMethod('loginInWithDouyin', {"scope": scope});
    return result;
  }

  @override
  Future<String?> initKey(String clientKey, String clientSecret) async {
    DyConf.clientKey = clientKey;
    DyConf.clientSecret = clientSecret;
    final result = await methodChannel.invokeMethod('initSdk', {"clientKey": clientKey});
    return result;
  }

  @override
  Future<String?> reNewRefreshToken(String refreshToken) {
    return TokenUtils().reNewRefreshToken(refreshToken);
  }

  @override
  Future<String?> getClientToken() {
    return TokenUtils().getClientToken();
  }

  @override
  Future<String?> reNewAccessToken(String refreshToken) {
    return TokenUtils().reNewAccessToken(refreshToken);
  }

  @override
  Future<dynamic> shareToEditPage(List<String> imgPathList, List<String> videoPathList, List<String> mHashTagList, bool shareToPublish, String mState, String appId, String appTitle, String description, String appUrl) async {
    final result = await methodChannel.invokeMethod<String>(shareToPublish ? 'shareToPublishPage' : 'shareToEditPage', {
      "imgPathList": imgPathList,
      "videoPathList": videoPathList,
      "mHashTagList": mHashTagList,
      "mState": mState,
      "appId": appId,
      "appTitle": appTitle,
      "description": description,
      "appUrl": appUrl,
    });
    debugPrint("shareToEditPage result is $result");
    return result;
  }

  @override
  Future shareVideo(String filePath, List<String> tags, String title, bool shareToPublish) async {
    final result = await methodChannel.invokeMethod<String>("shareVideo", {
      "filePath": filePath,
      "tags": tags,
      "title": title,
      "shareToPublish": shareToPublish,
    });
    debugPrint("shareVideo result is $result");
    return result;
  }
}
