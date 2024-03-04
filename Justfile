VERSION := `sed -n 's/^version: \([^+ ]*\).*/\1/p' pubspec.yaml`
VERSION_FULL := `sed -n 's/^version: \([^ ]*\).*/\1/p' pubspec.yaml`

# Build generated files
build-isar:
    @echo "------------------------------"
    @echo "Build Isar......."
    @flutter pub run build_runner build

# Build capture file
# build-capture:
#     @cd capture_py && python3 -m pipenv install && python3 -m pipenv run pyinstaller --onefile --clean --strip capture.py
#     @cp capture_py/dist/capture assets/capture/capture-{{VERSION}}

# Build Linux deb package
build-deb: build-isar
    @echo "------------------------------"
    @echo "Building for Linux......"
    @dart pub global activate flutter_distributor
    @export PATH="$PATH":"$HOME/.pub-cache/bin" && flutter_distributor package --platform linux --targets deb

# Install Linux deb package
install-deb: build-deb
    @echo "------------------------------"
    @echo "Installing for Linux......"
    @sudo dpkg -i ./dist/{{VERSION_FULL}}/lex-{{VERSION_FULL}}-linux.deb

# Update yarn packages
update-yarn:
    @echo "------------------------------"
    @echo "Updating yarn packages......"
    @yarn upgrade-interactive --latest

# Install Linux dev dependencies
install-linux-dev:
    @echo "------------------------------"
    @echo "Installing Linux dev dependencies......"
    @sudo apt-get install -y clang cmake \
          pkg-config liblzma-dev libgtk-3-dev \
          ninja-build libayatana-appindicator3-dev \
          keybinder-3.0 libnotify-dev libkeybinder-3.0-dev \
          libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
          gstreamer1.0-plugins-good gstreamer1.0-plugins-bad