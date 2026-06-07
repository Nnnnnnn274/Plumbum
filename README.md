# plumbum
A customization toolbox for iOS using Darksword kernel exploit!

## Supported Devices
All iOS/iPadOS 17.0-26.0.1 devices, except A19/M5 devices

## Features
- Escape app sandbox
- Remotely control or force-crash userspace processes
- Arbitrarily overwrite file data on SSV-protected root file systems
- Manipulate UID, GID, and sticky bits for target files
- Disable ASLR by setting `P_DISABLE_ASLR` to `launchd's proc->p_flag`

## Building

This project uses GitHub Actions CI for automated building. **Do not build locally on Windows** - this is an iOS project that requires macOS with Xcode.

### GitHub Actions CI

The project is automatically built via GitHub Actions when:
- Code is pushed to `main` or `develop` branches
- Pull requests are created
- Workflow is manually triggered from the Actions tab

### Build Artifacts

After a successful CI build, the IPA file is available as a downloadable artifact:
1. Go to the Actions tab in the GitHub repository
2. Select the latest workflow run
3. Download the `plumbum-ipa` artifact

### Local Building (macOS Only)

If you have macOS with Xcode installed, you can build locally:

```bash
# Using Makefile
make ipa

# Or using build script directly
./build.sh
```

**Note:** Local building requires:
- macOS with Xcode installed
- Xcode command line tools
- The project must be opened in Xcode at least once to configure schemes

### CI Workflow

The GitHub Actions workflow:
- Runs on macOS-latest runner
- Builds the app without code signing
- Exports as unsigned IPA
- Uploads IPA as artifact for download
- Retains artifacts for 30 days