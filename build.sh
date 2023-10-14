echo "------------------------------"
echo "Build Isar......."
flutter pub run build_runner build
echo "------------------------------"
echo "Building for Linux......"
dart pub global activate flutter_distributor
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutter_distributor package --platform linux --targets deb
echo "------------------------------"
echo "Build vitepress......"
cp ./CHANGELOG.md ./docs/changelog.md
yarn install
yarn docs:build