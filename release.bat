@echo off
rm -rf release release.zip
mkdir release
cp -R h3d haxelib.xml CHANGES.txt release
rm -rf release/*/.svn release/*/*/.svn
7z a -tzip release.zip release
rm -rf release
haxelib submit release.zip
pause