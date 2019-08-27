## Project setup and initialization
1.```npm i react-native-fauth```

2.```react-native link```

## Config
1. In file AndroidManifest.xml  add command tools:replace="android:theme" at application.
```
<application tools:replace="android:theme" android:name="ai.ftech.mama.MainApplication" android:label="@string/app_name" android:icon="@mipmap/ic_launcher" android:allowBackup="false" android:theme="@style/AppTheme">
```
2. In file build.gradle (android/app/build.gradle), add command manifestPlaceholders = [ 'appAuthRedirectScheme': 'mama.ftech.ai' ] at defaultConfig 
  ```diff
  defaultConfig {
        applicationId "ai.ftech.mama"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 2
        versionName "1.0.2"
        ndk {
            abiFilters "armeabi-v7a", "x86"
        }
+        manifestPlaceholders = [ 'appAuthRedirectScheme': 'mama.ftech.ai' ]
    }
  ```
  and add command at android inside app/build.gradle
  ```diff
+   compileOptions {
+        sourceCompatibility JavaVersion.VERSION_1_8
+        targetCompatibility JavaVersion.VERSION_1_8
    }
  ```
3. In file MainActivity.java, edit void onActivityResult add command 
  ```diff
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        MainApplication.getCallbackManager().onActivityResult(requestCode, resultCode, data);
+  if (resultCode == RESULT_OK && requestCode == RNReactNativeFauthModule.REQUEST_CODE) {
+      if (data.getBooleanExtra("success", false)) {
+          WritableMap params = Arguments.createMap();
+                String json = data.getStringExtra("json");
+                if (json != null) {
+                   params.putString("json", json);
+                    Log.d("WritableMap: ", json);
+                }
+                sendEvent(
+                        Objects.requireNonNull(getReactInstanceManager().getCurrentReactContext()),
+                        "onAuthenResult",
+                       params
+                );
+           }
+       }

    }
  ```
4. In file MainActivity.java, add void sendEvent
```diff
+import com.facebook.react.bridge.Arguments;
+import com.facebook.react.bridge.ReactContext;
+import com.facebook.react.bridge.WritableMap;
+import com.facebook.react.modules.core.DeviceEventManagerModule;
+import com.ftech.auth.RNReactNativeFauthModule;
+import android.support.annotation.Nullable;
+import android.util.Log;
+import java.util.Objects;

...

+ private void sendEvent(ReactContext reactContext,
+                               String eventName,
+                               @Nullable WritableMap params) {
+       reactContext
+                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
+                .emit(eventName, params);
+    }
```
## React-native code
1. Import modules from react-native
```diff
+ import {
+  NativeModules,
+  NativeEventEmitter,
+  DeviceEventEmitter,
+  Platform
+} from "react-native";
```
2. Add variable
```diff
+ var FAuthenLib = NativeModules.RNReactNativeFauthModule;
+ var subscription;
```
3. Processing login function
```diff
+ const oidc_issuer = "https://fid.ftech.ai"
+    const clientID = "mama_pkce"
+    const redirectURI = "mama.ftech.ai://callback"
+    const clientSecret = "c4903e14-f9b5-47ab-8ed4-83e073a5cb7c"
+    const scope = "mama fcall openid profile"
+    const authorizationEndpoint = "https://fid.ftech.ai/mama/connect/authorize"
+    const tokenEndpoint = "https://fid.ftech.ai/mama/connect/token"
+    FAuthenLib.showAuthenVC(
+      [oidc_issuer, clientID, redirectURI, clientSecret, scope, authorizationEndpoint, tokenEndpoint]);
```
4. Follow in componentDidMount()
```diff
componentDidMount() {
...
+    if (Platform.OS == 'ios') {
+     const myModuleEvt = new NativeEventEmitter(NativeModules.RNReactNativeFauthModule)
+      subscription = myModuleEvt.addListener(
+        'onAuthenResult',
+        (data) => {
+          console.log("test_onAuthenResult 123: ", data)
+        }
+      );
+    } else {
+      subscription = DeviceEventEmitter.addListener(
+        'onAuthenResult',
+        data => {
+          console.log("onAuthenResult: ", data)
+        });
+    }

  }
```
