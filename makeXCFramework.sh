rm -rf Vendor/*
rm -rf archives/*
rm -rf xcframeworks/*
cp -a ../plCrashReporter/xcframeworks/CrashReporter.xcframework Vendor/
xcodebuild archive -project Support/HockeySDK.xcodeproj -scheme "HockeySDK Framework" -configuration "ReleaseCrashOnly" -destination "generic/platform=iOS" -archivePath "archives/HockeySDK-iOS"
xcodebuild archive -project Support/HockeySDK.xcodeproj -scheme "HockeySDK Framework" -configuration "ReleaseCrashOnly" -destination "generic/platform=iOS Simulator" -archivePath "archives/HockeySDK-iOS_Simulator"
# iOS only xcframework
#xcodebuild -create-xcframework -archive archives/HockeySDK-iOS.xcarchive -framework HockeySDK.framework -archive archives/HockeySDK-iOS_Simulator.xcarchive -framework HockeySDK.framework -output xcframeworks/HockeySDK.xcframework
#
# this assumes HockeySDK-Mac repo is at the same level as this repo
#xcodebuild archive -project ../HockeySDK-Mac/Support/HockeySDK.xcodeproj -scheme "HockeySDK" -destination "generic/platform=macOS" -archivePath "archives/HockeySDK-macOS"
#

cp -a ../HockeySDK-Mac/archives/HockeySDK.xcarchive archives/HockeySDK-Mac.xcarchive

# combine iOS, iOS Simulator and macOS archives into a single HockeySDK.xcframework
xcodebuild -create-xcframework -archive archives/HockeySDK-iOS.xcarchive -framework HockeySDK.framework -archive archives/HockeySDK-iOS_Simulator.xcarchive -framework HockeySDK.framework -archive archives/HockeySDK-Mac.xcarchive -framework HockeySDK.framework -output xcframeworks/HockeySDK.xcframework
