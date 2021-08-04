package edu.ucsd.h4oceans.ecoapp.ocean_view;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
//import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.geofencing.GeofencingService;

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate();
        GeofencingService.setPluginRegistrant(this);
    }

    override fun registerWith(registry: PluginRegistry) {
        registry.registrarFor("io.flutter.plugins.geofencing.GeofencingService");
        //GeneratedPluginRegistrant.registerWith(registry);
    }
}