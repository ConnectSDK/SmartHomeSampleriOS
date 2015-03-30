# SmartHomeSampleriOS

##About
For information on Connect SDK, visit [connectsdk.com/discover](http://connectsdk.com/discover/).

##Setup

###Dependencies
- Add ConnectSDK for iOS to the project. See [link](https://github.com/ConnectSDK/Connect-SDK-iOS) for setup instructions
- Add Belkin [Wemo SDK](http://developers.belkin.com/wemo/sdk). Run wemo_duplicate_symbols_fix.sh in WeMoSDK folder
- Add [Philips Hue SDK](http://www.developers.meethue.com/documentation/apple-sdk). Add [Lumberjack](https://github.com/PhilipsHue/PhilipsHueSDK-iOS-OSX/tree/master/Lumberjack) which is required by Philips Hue.
- Add Nuance Dragon mobile [Speechkit framework](http://nuancemobiledeveloper.com/public/index.php). Update the variables kNuanceAppId, kNuanceAppHost, kNuanceAppHost and SpeechKitApplicationKey in Secret.m with the values provided . For instructions for SpeechKit setup see [this](http://dragonmobile.nuancemobiledeveloper.com/public/Help/DragonMobileSDKReference_iOS/SpeechKit_Guide/ServerConnection.html)
- Update Wink access parameters kWinkUsername, kWinkPassword, kWinkClientId, kWinkClientSecret

##See also
For more information on using Connect SDK, we recommend you review the following material.

- [Connect SDK iOS Docs](http://connectsdk.com/docs/ios)
- [API Documentation](http://connectsdk.com/apis/ios/)

##License
Smart Home Sample App by LG Electronics

To the extent possible under law, the person who associated CC0 with
this sample app has waived all copyright and related or neighboring rights
to the sample app.

You should have received a copy of the CC0 legalcode along with this
work. If not, see http://creativecommons.org/publicdomain/zero/1.0/.
