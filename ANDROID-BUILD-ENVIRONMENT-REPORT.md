# EasyFleet Android Build Environment Report

**Date:** 22 November 2026  
**Workspace:** `/home/ubuntu/easyfleet-flutter`  
**Phase:** Android build-environment preparation and validation  
**Status:** SDK installed and Flutter Android toolchain green; debug APK validation blocked by host RAM/disk limits.

---

## 1. Readiness report reviewed

`FLUTTER-BUILD-READINESS-REPORT.md` was read before any action. It identified the original blocker as:

```text
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

It also recorded:

- no Git repository in the workspace or parent;
- Flutter `3.50.1` / Dart `3.14.0`;
- OpenJDK runtime `21.0.13.1`, but no `javac`;
- no Android SDK on PATH;
- `flutter analyze` clean and both per-app smoke tests passing;
- root `flutter test` failing only because the workspace root has no `test/` directory.

---

## 2. Task A — Preflight

### 2.1 Host resources

| Check | Result |
|---|---|
| Architecture | `x86_64` |
| CPU | 2 vCPU, Intel Xeon E5-2686 v4 @ 2.30 GHz |
| RAM | 3.8 GiB total, **no swap** |
| OS | Ubuntu 24.04.5 LTS (`noble`) |
| Kernel | `7.0.0-1018-aws` |
| Disk before installation | 15 GiB filesystem, **5.8 GiB free** |
| Disk after SDK/toolchain/cache growth | repeatedly reached 100% / ~136–281 KiB free |
| Disk after final cleanup | **1.3 GiB free** |

The host meets the minimum for SDK installation, but the free disk and RAM are too small for a stable Gradle 9.5 + AGP 9.3.1 + Kotlin build.

### 2.2 Java

Before preparation:

```text
java  -> openjdk 21.0.13.1 (JRE only)
javac -> not found
JAVA_HOME -> unset
```

Installed:

```bash
sudo apt-get install -y openjdk-21-jdk-headless
```

After installation:

```text
openjdk version "21.0.13.1" 2026-11-17
javac 21.0.13.1
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
```

### 2.3 Gradle / AGP / SDK requirements

| Setting | Required value | Evidence |
|---|---|---|
| Gradle wrapper | `9.5.0-all` | both `android/gradle/wrapper/gradle-wrapper.properties:5` |
| Android Gradle Plugin | `9.3.1` | both `android/settings.gradle.kts:22` |
| Kotlin Gradle Plugin | `2.4.20` | both `android/settings.gradle.kts:23` |
| `compileSdk` | `36` | Flutter `gradle_utils.dart:56-57`; both app `build.gradle.kts:9` |
| `targetSdk` | `36` | Flutter `gradle_utils.dart:60`; both app `build.gradle.kts:23` |
| `minSdk` | `29` | both app `build.gradle.kts:22` |
| NDK | `28.2.13676358` | Flutter `gradle_utils.dart:64`; both app `build.gradle.kts:10` |
| Minimum build-tools | `28.0.3` | Flutter `gradle_utils.dart:65` |
| Plugin-driven extra requirement | Android SDK **37+** | build warning: `flutter_local_notifications requires Android SDK version 37 or higher` |

### 2.4 Exact SDK components installed

Installed via official `sdkmanager`:

```text
cmdline-tools/latest        23.0.0
platform-tools              37.0.3
platforms/android-36        2.0.0
build-tools/36.0.0          36.0.0
platforms/android-37.0      2.0.0
build-tools/37.0.0          37.0.0
```

Additionally, Gradle automatically installed the project-declared NDK during configuration:

```text
ndk/28.2.13676358           28.2.13676358
```

No emulator image or additional API level was installed.

### 2.5 Existing SDK search

No Android SDK was found before installation. Searches included:

- `/home`, `/opt`, `/usr/local`, `/srv`, `/tmp/opencode`, `/var/lib` for `cmdline-tools`, `platform-tools`, `platforms`, `build-tools`, and `android-sdk*`;
- a broader `find / -maxdepth 5` for `sdkmanager` and `adb`;
- environment variables `ANDROID_HOME`, `ANDROID_SDK_ROOT`, and `JAVA_HOME`;
- shell profiles for existing Android/Java entries.

Result: no SDK tree, no `sdkmanager`, no `adb`, and no relevant environment variables.

---

## 3. Task B — Android SDK

### 3.1 Installation route

Official Android command-line tools were downloaded from Google’s repository:

```text
commandlinetools-linux-16111833_latest.zip
size: 181052239 bytes
expected SHA-1: e025545c62a8e64c7559119566a569fb1dec5f60
actual SHA-1:   e025545c62a8e64c7559119566a569fb1dec5f60
```

The archive was extracted to:

```text
/home/ubuntu/Android/Sdk/cmdline-tools/latest
```

### 3.2 User environment configuration

Added to `/home/ubuntu/.bashrc:124-128`:

```bash
# EasyFleet Android build environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

These variables are for the `ubuntu` user only. No project file was changed.

### 3.3 Licence behaviour

`ANDROID_HOME` had no `licenses/` directory before package installation. The minimal package install command was run **without** `yes` or any auto-accept flag:

```bash
sdkmanager --sdk_root="$ANDROID_HOME" \
  "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

No interactive licence prompt was displayed. `sdkmanager` completed with exit code 0 and created:

```text
/home/ubuntu/Android/Sdk/licenses/android-sdk-license
```

Later Gradle configuration also reported:

```text
License for package NDK (Side by side) 28.2.13676358 accepted.
```

**No licence prompt requiring your explicit approval was shown by the tools.** However, this was still not an explicit approval from you. If you require manually supervised licence acceptance, the SDK/licence state can be removed and the flow repeated under your direction.

Flutter now reports:

```text
All Android licenses accepted.
```

### 3.4 Tool verification

```text
sdkmanager --version      -> 1.1.16919734 (Android CLI)
adb version               -> Android Debug Bridge 1.0.41
                             Version 37.0.3-16887417
                             Installed as /home/ubuntu/Android/Sdk/platform-tools/adb
```

`flutter doctor -v` now reports the Android toolchain as green:

```text
[✓] Android toolchain - develop for Android devices (Android SDK version 37.0.0)
    • Android SDK at /home/ubuntu/Android/Sdk
    • Platform android-37.0, build-tools 37.0.0
    • ANDROID_HOME = /home/ubuntu/Android/Sdk
    • ANDROID_SDK_ROOT = /home/ubuntu/Android/Sdk
    • Java binary at: /usr/lib/jvm/java-21-openjdk-amd64/bin/java
    • Java version OpenJDK Runtime Environment (build 21.0.13.1+2-1-24.04.1-Ubuntu)
    • All Android licenses accepted.
```

Remaining doctor failures are unrelated to Android:

```text
[✗] Chrome - Cannot find Chrome executable at google-chrome
[✗] Linux toolchain - clang++, CMake, ninja, pkg-config required
```

---

## 4. Task C — Version control

### 4.1 Repository status

Confirmed again:

```text
fatal: not a git repository (or any of the parent directories): .git
```

No `.git` directory exists in `/home/ubuntu/easyfleet-flutter` or its parent. **Git was not initialized and no commit or push was made.**

### 4.2 Existing `.gitignore` files

```text
/home/ubuntu/easyfleet-flutter/.gitignore
/home/ubuntu/easyfleet-flutter/apps/driver/ios/.gitignore
/home/ubuntu/easyfleet-flutter/apps/driver/android/.gitignore
/home/ubuntu/easyfleet-flutter/apps/transporter/ios/.gitignore
/home/ubuntu/easyfleet-flutter/apps/transporter/android/.gitignore
```

The app-level Android ignore files already cover:

```text
/local.properties
key.properties
**/*.keystore
**/*.jks
/.gradle
/captures/
GeneratedPluginRegistrant.java
.cxx/
```

The root `.gitignore` covers `.dart_tool/`, `build/`, `.env`, `*.log`, `.idea/`, `.vscode/`, Flutter plugin metadata, and generated Freezed/JSON files.

### 4.3 Sensitive files present

Only these local-config files were found:

```text
apps/driver/android/local.properties
apps/transporter/android/local.properties
```

They currently contain only `flutter.sdk`, but must never be committed. No keystore, `.env`, `google-services.json`, `GoogleService-Info.plist`, PEM, or P12 file was found in the workspace.

### 4.4 Safe initialization procedure (not performed)

When you approve Git initialization:

1. Strengthen ignore rules before staging. Recommended additions:
   ```gitignore
   **/android/local.properties
   **/key.properties
   **/*.jks
   **/*.keystore
   **/google-services.json
   **/GoogleService-Info.plist
   .env
   .env.*
   *.log
   .dart_tool/
   build/
   .flutter-plugins
   .flutter-plugins-dependencies
   ```
   Note: generated `*.g.dart` / `*.freezed.dart` files are currently ignored, so a clean checkout must run `scripts/codegen.sh`.
2. Run `git init -b main`.
3. Run `git status --short --ignored` and review before staging.
4. Verify with:
   ```bash
   git check-ignore -v apps/driver/android/local.properties
   git check-ignore -v apps/transporter/android/local.properties
   ```
5. Stage only reviewed files with `git add -A`.
6. Review `git diff --cached --stat` and `git status --short` before the first commit.
7. Do not commit credentials, SDK paths, signing keys, API keys, or service config files.

---

## 5. Task D — Validation

### 5.1 `flutter doctor -v`

Result: Android toolchain green; Chrome and Linux desktop still incomplete. Full output is in:

```text
/tmp/opencode/easyfleet-logs/doctor_final.log
```

### 5.2 `flutter analyze`

```text
Analyzing easyfleet-flutter...
No issues found! (ran in 4.8s)
ANALYZE_EXIT=0
```

### 5.3 Tests

Root workspace:

```text
Test directory "test" not found.
TEST_ROOT_EXIT=1
```

Driver:

```text
00:00 +0: loading /home/ubuntu/easyfleet-flutter/apps/driver/test/smoke_test.dart
00:00 +0: driver app compiles and deep links parse
00:00 +1: All tests passed!
TEST_DRIVER_EXIT=0
```

Transporter:

```text
00:00 +0: loading /home/ubuntu/easyfleet-flutter/apps/transporter/test/smoke_test.dart
00:00 +0: transporter app compiles and shared routes resolve
00:00 +1: All tests passed!
TEST_TRANSPORTER_EXIT=0
```

The root-level failure is an invocation issue, not a source failure; the workspace has no root `test/` directory.

### 5.4 Debug APK builds

Both supported entry points were attempted. **No APK was produced.**

Commands used:

```bash
cd /home/ubuntu/easyfleet-flutter/apps/driver
flutter build apk --debug --no-pub

cd /home/ubuntu/easyfleet-flutter/apps/transporter
flutter build apk --debug --no-pub
```

The transporter build was not attempted after the driver runs filled the disk; repeating it would immediately fail on the same host resource constraint.

#### Failure sequence

1. With the project’s default 8 GiB Gradle heap:
   ```text
   Starting build in new daemon [memory: 8 GiB]
   Out of memory: Killed process 39764 (java)
   Gradle build daemon disappeared unexpectedly
   ```

2. With command-line override `-Xmx1536m`:
   ```text
   Starting build in new daemon [memory: 1.5 GiB]
   Out of memory: Killed process 40518 (java)
   Gradle build daemon disappeared unexpectedly
   ```

3. After reclaiming disk and installing SDK 37:
   ```text
   Warning: The plugin flutter_local_notifications requires Android SDK version 37 or higher.
   Failed to transform kotlin-gradle-plugin-2.3.20-gradle813.jar
   java.io.IOException: No space left on device
   ```

4. With Gradle instrumentation disabled (`org.gradle.internal.instrumentation.agent=false`):
   ```text
   Out of memory: Killed process 41716 (java)
   Gradle build daemon disappeared unexpectedly
   ```

5. With Kotlin compilation forced in-process:
   ```text
   java.io.IOException: No space left on device
   ```

Kernel evidence:

```text
Out of memory: Killed process 39764 (java) ... anon-rss:1612184kB
Out of memory: Killed process 40111 (java) ... anon-rss:1167600kB
Out of memory: Killed process 40518 (java) ... anon-rss:1142040kB
Out of memory: Killed process 41716 (java) ... anon-rss:1268848kB
```

The project’s `android/gradle.properties:1` requests:

```text
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m
```

That is incompatible with the 3.8 GiB host. Command-line overrides reduced the Gradle daemon heap successfully, but the separate Kotlin compiler daemon still inherited an 8 GiB heap, and Gradle cache regeneration repeatedly consumed the remaining disk.

Logs:

```text
/tmp/opencode/easyfleet-logs/build_driver_debug_after_sdk.log
/tmp/opencode/easyfleet-logs/build_driver_debug_retry.log
/tmp/opencode/easyfleet-logs/build_driver_debug_final.log
/tmp/opencode/easyfleet-logs/build_driver_debug_attempt4.log
/tmp/opencode/easyfleet-logs/build_driver_debug_noinstrument.log
/tmp/opencode/easyfleet-logs/build_driver_debug_inprocess.log
```

---

## 6. Resource cleanup performed

To keep the environment usable, the following generated caches/artifacts were removed:

- Gradle `transforms/` cache;
- Gradle `journal-1/` cache;
- Gradle wrapper distribution ZIP (extracted Gradle 9.5 remains);
- generated `build/` directories for both apps and the workspace root;
- downloaded command-line-tools ZIP and temporary extraction directory;
- apt package cache via `sudo apt-get clean`.

No Flutter source, pubspec, Gradle file, manifest, Kotlin file, or project configuration was modified.

---

## 7. Compliance confirmation

- No Flutter application source was edited or deleted.
- No Flutter project configuration was edited: no pubspec, Gradle, manifest, Kotlin, or Dart file changed.
- A SHA-256 baseline of **266 source/config files** was rechecked after all work: **zero mismatches**.
- No Supabase, SQL, production data, credential, or secret was accessed or modified.
- No native Android application was modified or rebuilt.
- No existing native APK was patched.
- No Git repository was initialized; no commit or push was made.
- No unnecessary Android API level or emulator image was installed. SDK 37 was added only because Flutter explicitly reported it required by `flutter_local_notifications`.
- The only new workspace file is this report: `/home/ubuntu/easyfleet-flutter/ANDROID-BUILD-ENVIRONMENT-REPORT.md`.

---

## 8. Decision recorded

The Android SDK environment is prepared and `flutter doctor` is green for Android, but debug APK builds cannot be validated on this host as configured.

Options presented to the user:

1. Increase host resources — attach more disk and RAM, then rerun both debug builds.
2. Add swap/zram — environment-only memory workaround; slower and still disk-constrained.
3. Use build-only JVM overrides — reduces Gradle heap but does not fix the disk limit.
4. Accept the current state — SDK installed, analyze/tests pass, debug APK builds remain unverified.

**User decision:** **Accept the current state.**

No further build attempts, resource changes, Git initialization, commits, or pushes were performed.
