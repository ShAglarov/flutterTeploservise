#ifndef RUNNER_WNS_CHANNEL_PLUGIN_H_
#define RUNNER_WNS_CHANNEL_PLUGIN_H_

#include <flutter/flutter_engine.h>

// Registers the WNS channel platform channel with the Flutter engine.
// This plugin responds to "getWnsChannelUri" calls from Dart
// by using C++/WinRT to request a WNS push notification channel URI.
void RegisterWnsChannelPlugin(flutter::FlutterEngine* engine);

#endif  // RUNNER_WNS_CHANNEL_PLUGIN_H_
