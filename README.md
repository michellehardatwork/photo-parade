
# Photo Parade
![alt text](https://github.com/michellehardatwork/photo-parade/raw/master/PhotoParade/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5%402x.png "Photo Parade Logo")

This Swift application uses the [Fliker Photo API](https://www.flickr.com/services/api/) to display a collection view of photos.  The view restricts the display to 2 columns in Portrait view and 2 rows in Landscape view.  Scrolling to the end of the collection will initiate a call to get more data.

## Run
1. `git clone https://github.com/michellehardatwork/photo-parade.git`
2.  Add a Keys.plist file to the `photo-parade/PhotoParade` directory.  
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>FLICKR_API_KEY</key>
	<string>xxxx_YOUR_TOKEN_HERE_xxxx</string>
</dict>
</plist>
```
3.  Open `PhotoParade.xcodeproj` using XCode 9.1
4.  Build/Run using XCode

## Outstanding Items

* Finish out unit tests & UI tests
* The images should be cached, and then clear the cache when the search parameters change
* Display a default/loading image and an error state image
* Need to implement the drill down detail view for photos

## Optional Dependencies
The project uses [SwiftLint](https://github.com/realm/SwiftLint) to validate formatting.  A warning will display while building if you don't have this installed.  

> SwiftLint not installed, download from https://github.com/realm/SwiftLint

Although optional, to install run
```
brew install swiftlint
```


