# Icon design

Design specs: https://developer.android.com/google-play/resources/icon-design-specifications

Icon is loosely based off of the material design stopwatch icon.

icons/player-in-stopwatch-base.paint

* Outline is in a vector style format, used by Paint S. (Inexpensive MacOS
vector graphics software.)
* 1024 x 1024 pixels
* single color + transparent background.

icons/player-in-stopwatch-base.png

* PNG version of the outline, 1024 x 1024, 300 dpi


# Generating for Android

Use [Roman Nurik's generator](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html).

Link with config options: https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html#foreground.type=image&foreground.space.trim=1&foreground.space.pad=0.2&foreColor=rgb(255%2C%20255%2C%20255)&backColor=rgb(68%2C%20138%2C%20255)&crop=1&backgroundShape=square&effects=shadow&name=ic\_launcher

* Image: icons/player-in-stopwatch-base.png
* Padding: 20%
* Color: white
* Background color: pretty bluish color
* Scaling: Crop
* Shape: Square
* Effect: Cast shadow
* Name: ic\_launcher

Unzip ic\_launcher.zip into android/app/src/main

```
$ unzip ~/Downloads/ic_launcher.zip
Archive:  /Users/brian/Downloads/ic_launcher.zip
replace res/mipmap-xxxhdpi/ic_launcher.png? [y]es, [n]o, [A]ll, [N]one, [r]ename: A
 extracting: res/mipmap-xxxhdpi/ic_launcher.png
 extracting: web_hi_res_512.png
 extracting: res/mipmap-xxhdpi/ic_launcher.png
 extracting: res/mipmap-xhdpi/ic_launcher.png
 extracting: res/mipmap-hdpi/ic_launcher.png
 extracting: res/mipmap-mdpi/ic_launcher.png
```

# Generating for iOS

Use https://appicon.co/.

Upload the web\_hi\_res\_512.png file (they want 1024x1024, but this is good
enough.)

Select all of the iOS and Mac options. Unset the Android options.

Download the new icons.

Unzip into ios/Runner to replace files in Assets.xcassets:

```
$  unzip ~/Downloads/AppIcons.zip 
Archive:  /Users/brian/Downloads/AppIcons.zip
 extracting: Assets.xcassets/AppIcon.appiconset/80.png  
 extracting: appstore.png            
 extracting: Assets.xcassets/AppIcon.appiconset/152.png  
 extracting: Assets.xcassets/AppIcon.appiconset/100.png  
 extracting: Assets.xcassets/AppIcon.appiconset/1024.png  
 extracting: Assets.xcassets/AppIcon.appiconset/58.png  
 extracting: Assets.xcassets/AppIcon.appiconset/76.png  
 extracting: Assets.xcassets/AppIcon.appiconset/29.png  
 extracting: Assets.xcassets/AppIcon.appiconset/50.png  
 extracting: Assets.xcassets/AppIcon.appiconset/144.png  
 extracting: Assets.xcassets/AppIcon.appiconset/40.png  
 extracting: Assets.xcassets/AppIcon.appiconset/167.png  
 extracting: Assets.xcassets/AppIcon.appiconset/20.png  
 extracting: Assets.xcassets/AppIcon.appiconset/172.png  
 extracting: Assets.xcassets/AppIcon.appiconset/88.png  
 extracting: Assets.xcassets/AppIcon.appiconset/196.png  
 extracting: Assets.xcassets/AppIcon.appiconset/216.png  
 extracting: Assets.xcassets/AppIcon.appiconset/48.png  
 extracting: Assets.xcassets/AppIcon.appiconset/55.png  
 extracting: Assets.xcassets/AppIcon.appiconset/87.png  
 extracting: Assets.xcassets/AppIcon.appiconset/128.png  
 extracting: Assets.xcassets/AppIcon.appiconset/256.png  
 extracting: Assets.xcassets/AppIcon.appiconset/64.png  
 extracting: playstore.png           
 extracting: Assets.xcassets/AppIcon.appiconset/180.png  
 extracting: Assets.xcassets/AppIcon.appiconset/120.png  
 extracting: Assets.xcassets/AppIcon.appiconset/57.png  
 extracting: Assets.xcassets/AppIcon.appiconset/114.png  
 extracting: Assets.xcassets/AppIcon.appiconset/60.png  
 extracting: Assets.xcassets/AppIcon.appiconset/72.png  
 extracting: Assets.xcassets/AppIcon.appiconset/512.png  
 extracting: Assets.xcassets/AppIcon.appiconset/32.png  
 extracting: Assets.xcassets/AppIcon.appiconset/16.png  
replace Assets.xcassets/AppIcon.appiconset/Contents.json? [y]es, [n]o, [A]ll, [N]one, [r]ename: A
 extracting: Assets.xcassets/AppIcon.appiconset/Contents.json  
```
