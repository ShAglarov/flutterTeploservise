#include "wns_channel_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Networking.PushNotifications.h>

#include <iostream>
#include <memory>
#include <string>

using namespace winrt;
using namespace winrt::Windows::Foundation;
using namespace winrt::Windows::Networking::PushNotifications;

// Helper: convert std::wstring to std::string (UTF-8)
static std::string WideToUtf8(const std::wstring &wide) {
  if (wide.empty())
    return {};
  int sizeNeeded = WideCharToMultiByte(CP_UTF8, 0, wide.c_str(),
                                       static_cast<int>(wide.size()), nullptr,
                                       0, nullptr, nullptr);
  std::string result(sizeNeeded, 0);
  WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), static_cast<int>(wide.size()),
                      &result[0], sizeNeeded, nullptr, nullptr);
  return result;
}

void RegisterWnsChannelPlugin(flutter::FlutterEngine *engine) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          engine->messenger(), "com.teploservice/wns",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue> &call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        if (call.method_name() == "getWnsChannelUri") {
          // We need to run the async WinRT call.
          // Capture result as shared_ptr so we can move into the lambda.
          auto shared_result =
              std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(
                  std::move(result));

          try {
            // Initialize WinRT (safe to call multiple times).
            winrt::init_apartment(winrt::apartment_type::single_threaded);

            auto channelOp = PushNotificationChannelManager::
                CreatePushNotificationChannelForApplicationAsync();

            // Use a completed handler so we don't block the UI thread.
            channelOp.Completed(
                [shared_result](
                    IAsyncOperation<PushNotificationChannel> const &op,
                    AsyncStatus status) {
                  try {
                    if (status == AsyncStatus::Completed) {
                      auto pushChannel = op.GetResults();
                      auto uri = pushChannel.Uri();
                      std::string uriStr = WideToUtf8(std::wstring(uri));
                      shared_result->Success(flutter::EncodableValue(uriStr));
                    } else {
                      shared_result->Error(
                          "WNS_ERROR",
                          "Failed to create push notification channel");
                    }
                  } catch (const winrt::hresult_error &ex) {
                    std::string msg = WideToUtf8(std::wstring(ex.message()));
                    shared_result->Error("WNS_HRESULT_ERROR", msg);
                  } catch (const std::exception &ex) {
                    shared_result->Error("WNS_EXCEPTION", ex.what());
                  }
                });
          } catch (const winrt::hresult_error &ex) {
            std::string msg = WideToUtf8(std::wstring(ex.message()));
            shared_result->Error("WNS_INIT_ERROR", msg);
          } catch (const std::exception &ex) {
            shared_result->Error("WNS_INIT_EXCEPTION", ex.what());
          }
        } else {
          result->NotImplemented();
        }
      });
}
