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
