# SmartHomeSampleriOS app

## About

This demo app demonstrates a scenario of using various Smart Home devices in two home scenes. They represent a living room and a family room, each containing a media device, light bulbs, and possibly other devices. The supported devices come from different categories (media players, light bulbs, switches, and iBeacons) and multiple manufacturers.

We belive the Smart Homes of the future, are not going to be driven by devices from a single manufacturer, instead a network of devices from various manufacturers.

The scenario of the app is:
1. You enter the living room, which is detected by an iBeacon, 
2. A playlist starts to play on a TV or speaker, and the light bulbs change color to match one of the colors of the album art during playback.
3. Then the user moves from the living room scene to the family room scene.
4. Where the session information is transfered from the living room to the family room.
4.1 The devices in the living switch off and the session is picked up in the family room
5. The user put the scene to sleep using voice command (to replicate control using Siri or Google Now or other voice engine/assitants)
5.1 The speaker fades out  the music, while the LED bulb fade out and switch off.
6. The Scene wakes up after a defined time - to mimic waking up from an alarm.
6.1 The LEd Bulbs switch on along with speaker. 

For additional information on Connect SDK, visit [http://connectsdk.com/discover/](http://connectsdk.com/discover/).

### Prerequisites

Devices used:

* LG WebOS TV or DLNA-compatible media device for each scene, such as Sonos speakers.

The app has been tested and works with these devices:

* [LG WebOS 2014 TV](http://www.lg.com/us/experience-tvs/smart-tv)
* [Sonos PLAY:1 speaker](http://www.sonos.com/sonos-shop/products/play1)
* [Philips Hue hub and bulbs](http://www2.meethue.com/en-us/)
* [Belkin WeMo Switch](http://www.belkin.com/us/p/F7C027fc/)
* [Wink hub](http://www.wink.com/products/wink-hub/) + [GE link light bulb](http://gelinkbulbs.com)
* [StickNFind iBeacons](https://www.sticknfind.com/sticknfind.aspx)

**Important**: Make sure all the WiFi-supported devices (WebOS TV, Sonos speaker, Philips Hue hub, WeMo switch, and Wink hub) and your iOS device with the app are connected to the same WiFi network. To configure the devices, you need to use their respective apps.

### Limitations

The app must be in the foreground with the screen unlocked to work properly with the devices.

## Setup

### Dependencies

- Add ConnectSDK for iOS to the project. See [link](https://github.com/ConnectSDK/Connect-SDK-iOS) for setup instructions.
- Belkin WeMo SDK: Get it from [http://developers.belkin.com/wemo/sdk](http://developers.belkin.com/wemo/sdk), `unzip` the file you'll receive, and copy the contents of the `-iphoneos/` directory into `SmartHomeSampleriOS/WeMoSDK/` directory. To fix the `duplicate symbols` errors during linking, patch one of the libraries by running the `SmartHomeSampleriOS/WeMoSDK/wemo_duplicate_symbols_fix.sh` script.
- [Philips Hue SDK](http://www.developers.meethue.com/documentation/apple-sdk): Place the `HueSDK_iOS.framework` into `SmartHomeSampleriOS/PhilipsHue/` directory. Add [Cocoa Lumberjack](https://github.com/PhilipsHue/PhilipsHueSDK-iOS-OSX/tree/master/Lumberjack), which is required by Philips Hue, into `SmartHomeSampleriOS/PhilipsHue/`.
- Nuance Dragon mobile [SpeechKit framework](http://nuancemobiledeveloper.com/public/index.php): Place the `SpeechKit.framework` into `SmartHomeSampleriOS/Nuance/` directory. Update the variables `kNuanceAppId`, `kNuanceAppHost`, `kNuanceAppHost` and `SpeechKitApplicationKey` in `SmartHomeSampleriOS/Secret.m` with the values provided. For instructions for SpeechKit setup, see [this document](http://dragonmobile.nuancemobiledeveloper.com/public/Help/DragonMobileSDKReference_iOS/SpeechKit_Guide/ServerConnection.html).
- [Wink API](http://docs.wink.apiary.io): Update the following access parameters: `kWinkUsername`, `kWinkPassword`, `kWinkClientId`, and `kWinkClientSecret` in `SmartHomeSampleriOS/Secret.m`.

### Scenes Configuration

At first launch, you are able to pick devices for your scenes. You can use the "Configure" button later to change the config.

**Important**: Make sure to select different devices for the scenes.

## See also

For more information on using Connect SDK, we recommend you review the following material:

- [Connect SDK iOS Docs](http://connectsdk.com/docs/ios)
- [API Documentation](http://connectsdk.com/apis/ios/)

## License

Copyright 2015 LG Electronics

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
