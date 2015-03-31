# SmartHomeSampleriOS app

## About

For information on Connect SDK, visit [http://connectsdk.com/discover/](http://connectsdk.com/discover/).

## Setup

### Dependencies

- Add ConnectSDK for iOS to the project. See [link](https://github.com/ConnectSDK/Connect-SDK-iOS) for setup instructions.
- Belkin WeMo SDK: Get it from [http://developers.belkin.com/wemo/sdk](http://developers.belkin.com/wemo/sdk), `unzip` the file you'll receive, and copy the contents of the `-iphoneos/` directory into `SmartHomeSampleriOS/WeMoSDK/` directory. To fix the `duplicate symbols` errors during linking, patch one of the libraries by running the `SmartHomeSampleriOS/WeMoSDK/wemo_duplicate_symbols_fix.sh` script.
- [Philips Hue SDK](http://www.developers.meethue.com/documentation/apple-sdk): Place the `HueSDK_iOS.framework` into `SmartHomeSampleriOS/PhilipsHue/` directory. Add [Cocoa Lumberjack](https://github.com/PhilipsHue/PhilipsHueSDK-iOS-OSX/tree/master/Lumberjack), which is required by Philips Hue, into `SmartHomeSampleriOS/PhilipsHue/`.
- Nuance Dragon mobile [SpeechKit framework](http://nuancemobiledeveloper.com/public/index.php): Place the `SpeechKit.framework` into `SmartHomeSampleriOS/Nuance/` directory. Update the variables `kNuanceAppId`, `kNuanceAppHost`, `kNuanceAppHost` and `SpeechKitApplicationKey` in `SmartHomeSampleriOS/Secret.m` with the values provided. For instructions for SpeechKit setup, see [this document](http://dragonmobile.nuancemobiledeveloper.com/public/Help/DragonMobileSDKReference_iOS/SpeechKit_Guide/ServerConnection.html).
- [Wink API](http://docs.wink.apiary.io): Update the following access parameters: `kWinkUsername`, `kWinkPassword`, `kWinkClientId`, and `kWinkClientSecret` in `SmartHomeSampleriOS/Secret.m`.

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
