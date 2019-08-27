## Project setup and initialization
1.```react-native-fauth```
4.```react-native link```
5. Trong file AndroidManifest.xml  thêm tools:replace="android:theme" trong application.
```
<application tools:replace="android:theme" android:name="ai.ftech.mama.MainApplication" android:label="@string/app_name" android:icon="@mipmap/ic_launcher" android:allowBackup="false" android:theme="@style/AppTheme">
```
6. Trong file build.gradle (android/app/build.gradle), thêm câu lệnh manifestPlaceholders = [ 'appAuthRedirectScheme': 'mama.ftech.ai' ] vào trong phần defaultConfig
  ```
  defaultConfig {
        applicationId "ai.ftech.mama"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 2
        versionName "1.0.2"
        ndk {
            abiFilters "armeabi-v7a", "x86"
        }
        manifestPlaceholders = [ 'appAuthRedirectScheme': 'mama.ftech.ai' ]
    }
  ```
7. Trong file MainActivity.java, Sửa phần void onActivityResult thêm các câu dòng lệnh 
  ```diff
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        MainApplication.getCallbackManager().onActivityResult(requestCode, resultCode, data);
+  if (resultCode == RESULT_OK && requestCode == RNReactNativeFauthModule.REQUEST_CODE) {
+      if (data.getBooleanExtra("success", false)) {
+          WritableMap params = Arguments.createMap();
      +          String json = data.getStringExtra("json");
      +          if (json != null) {
      +              params.putString("json", json);
      +              Log.d("WritableMap: ", json);
      +          }
      +          sendEvent(
      +                  Objects.requireNonNull(getReactInstanceManager().getCurrentReactContext()),
      +                  "onAuthenResult",
      +                 params
      +          );
      +     }
      +  }

    }
  ```
  
