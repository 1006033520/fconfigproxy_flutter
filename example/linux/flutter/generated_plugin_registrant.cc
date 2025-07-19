//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fconfigproxy/fconfigproxy_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) fconfigproxy_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FconfigproxyPlugin");
  fconfigproxy_plugin_register_with_registrar(fconfigproxy_registrar);
}
