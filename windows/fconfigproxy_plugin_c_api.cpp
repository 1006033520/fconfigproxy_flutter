#include "include/fconfigproxy/fconfigproxy_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "fconfigproxy_plugin.h"

void FconfigproxyPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  fconfigproxy::FconfigproxyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
