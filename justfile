VERSION := `sed -n 's/^version: \([^ ]*\).*/\1/p' pubspec.yaml`

# Build generated files
build-isar:
    @echo "------------------------------"
    @echo "Build Isar......."
    @flutter pub run build_runner build

# Build Linux deb package
build-linux-deb:
    @echo "------------------------------"
    @echo "Building for Linux......"
    @dart pub global activate flutter_distributor
    @export PATH="$PATH":"$HOME/.pub-cache/bin" && flutter_distributor package --platform linux --targets deb

# Install Linux deb package
install-linux-deb: build-linux-deb
    @echo "------------------------------"
    @echo "Installing for Linux......"
    @sudo dpkg -i ./dist/{{VERSION}}/lex-{{VERSION}}-linux.deb

# Update yarn packages
update-yarn:
    @echo "------------------------------"
    @echo "Updating yarn packages......"
    @yarn upgrade-interactive --latest