//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <agora_rtc_engine/agora_rtc_engine_plugin.h>
#include <url_launcher_windows/url_launcher_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AgoraRtcEnginePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AgoraRtcEnginePlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
}
