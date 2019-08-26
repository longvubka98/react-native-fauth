
# react-native-react-native-fauth

## Getting started

`$ npm install react-native-react-native-fauth --save`

### Mostly automatic installation

`$ react-native link react-native-react-native-fauth`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-react-native-fauth` and add `RNReactNativeFauth.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativeFauth.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactNativeFauthPackage;` to the imports at the top of the file
  - Add `new RNReactNativeFauthPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-react-native-fauth'
  	project(':react-native-react-native-fauth').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-react-native-fauth/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-react-native-fauth')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNReactNativeFauth.sln` in `node_modules/react-native-react-native-fauth/windows/RNReactNativeFauth.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using React.Native.Fauth.RNReactNativeFauth;` to the usings at the top of the file
  - Add `new RNReactNativeFauthPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNReactNativeFauth from 'react-native-react-native-fauth';

// TODO: What to do with the module?
RNReactNativeFauth;
```
  