//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <firexcode/firexcode_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) firexcode_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FirexcodePlugin");
  firexcode_plugin_register_with_registrar(firexcode_registrar);
}
