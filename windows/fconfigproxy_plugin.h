#ifndef FLUTTER_PLUGIN_FCONFIGPROXY_PLUGIN_H_
#define FLUTTER_PLUGIN_FCONFIGPROXY_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace fconfigproxy {

class FconfigproxyPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FconfigproxyPlugin();

  virtual ~FconfigproxyPlugin();

  // Disallow copy and assign.
  FconfigproxyPlugin(const FconfigproxyPlugin&) = delete;
  FconfigproxyPlugin& operator=(const FconfigproxyPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace fconfigproxy

#endif  // FLUTTER_PLUGIN_FCONFIGPROXY_PLUGIN_H_
