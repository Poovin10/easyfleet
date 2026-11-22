# EasyFleet low-cost Android build path

Date: 2026-11-22

## Gate status

Implementation remains **closed**. No source, project configuration, backend, SQL, credentials, local `local.properties` files, native APKs, EC2 instance, or Gradle/Kotlin project files were changed. No Git repository was created, no commit or push was made, and no local Gradle build was rerun.

## What was done with skills.sh

- Confirmed there is no local `skill.sh` script; the request maps to the skills.sh / `npx skills` ecosystem.
- Searched the catalogue with `npx skills find` for Flutter Android builds, CI/CD, and GitHub Actions.
- Verified candidates against install count, repository reputation, and security audits before selecting anything.
- Installed two verified skills globally for OpenCode:
  - `thienqo/flutter-skills@flutter-ci-cd` — 120 installs, 18 GitHub stars, Gen Agent Trust Hub Pass, Socket Pass, Snyk Pass.
  - `thienqo/flutter-skills@flutter-build-release` — 123 installs, 18 GitHub stars, Gen Agent Trust Hub Pass, Socket Pass, Snyk Pass.
- Rejected weaker matches such as `dzianisv/skills@flutter-android-release` (1 install, 4 stars) and React-Native-specific `callstackincubator/agent-skills@github-actions` despite its high install count.

## Verdict

The lowest-cost viable path is **GitHub Actions on a standard Linux runner** (`ubuntu-latest` or preferably pinned `ubuntu-24.04`), triggered manually first.

This avoids:

- buying or resizing EC2,
- needing a Windows PC,
- deleting local caches or SDK packages,
- editing the checked-in Flutter/Gradle configuration,
- running another memory-hungry Gradle build on the current 3.8 GiB host.

GitHub-hosted Linux runner facts relevant here:

| Repository visibility | Runner | vCPU | RAM | SSD | Cost |
| --- | --- | ---: | ---: | ---: | --- |
| Public | `ubuntu-latest` / `ubuntu-24.04` | 4 | 16 GB | 14 GB | Free for standard runners |
| Private | `ubuntu-latest` / `ubuntu-24.04` | 2 | 8 GB | 14 GB | Included monthly compute allowance, then per-minute billing |

GitHub Free currently includes **$12/month** of compute for private repositories (about **2,000 minutes** on a 2-core Linux runner). Public repositories get free standard-runner minutes. A spend/budget limit should be set before any private-repo run.

## Why this fits the current failures

Current EC2 host:

- `t2.medium`, 2 vCPU, 3.8 GiB RAM, 0 swap, 16 GiB EBS with about 1.3 GiB free.
- Both apps request `org.gradle.jvmargs=-Xmx8G` in `android/gradle.properties`.
- Local debug builds were killed by OOM and then by `No space left on device`.

CI avoids the local disk/RAM ceiling. The checked-in 8 GiB heap still must not be trusted on an 8 GiB private runner. It can be overridden **without editing project files** by writing a user-level Gradle property file on the ephemeral runner. Gradle gives `GRADLE_USER_HOME/gradle.properties` higher precedence than the project's `gradle.properties`.

CI-only override shape, to be used inside the workflow before `flutter build apk`:

```sh
mkdir -p "$HOME/.gradle"
{
  echo 'org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g -XX:ReservedCodeCacheSize=512m -XX:+UseG1GC'
  echo 'kotlin.daemon.jvmargs=-Xmx2g'
  echo 'org.gradle.daemon=false'
} >> "$HOME/.gradle/gradle.properties"
```

This affects only the disposable CI VM. It does not alter `apps/driver/android/gradle.properties` or `apps/transporter/android/gradle.properties`.

## Proposed workflow shape (not created)

Initial trigger: `workflow_dispatch` only. No push or pull-request trigger until the first build is proven and the budget is understood.

Jobs:

1. **Validate**
   - Checkout.
   - Set up Java 21 and Flutter **3.50.1 stable** (Dart 3.14.0), matching the locally verified toolchain.
   - `flutter pub get` at workspace root.
   - `flutter format --set-exit-if-changed .` as a check only.
   - `flutter analyze`.
   - Run tests from each app directory, because the repository has no root `test/` directory:
     - `cd apps/driver && flutter test`
     - `cd apps/transporter && flutter test`

2. **Build driver debug APK**
   - Needs `validate`.
   - Apply the CI-only Gradle/Kotlin heap override above.
   - `flutter build apk --debug` from `apps/driver`.
   - Upload `apps/driver/build/app/outputs/flutter-apk/app-debug.apk` as a bounded-retention artifact.

3. **Build transporter debug APK**
   - Needs `validate`.
   - Same CI-only heap override.
   - `flutter build apk --debug` from `apps/transporter`.
   - Upload `apps/transporter/build/app/outputs/flutter-apk/app-debug.apk` as a bounded-retention artifact.

Caching rules from the installed CI skill:

- Cache Pub dependencies and Gradle dependency caches only.
- Key caches with runner OS/architecture, Flutter/Dart version, and `pubspec.lock`.
- Do not cache broad mutable directories such as `build/` or `.dart_tool/`.
- Cold-cache and warm-cache runs must execute the same correctness gates.

Delivery boundaries:

- Build and upload **debug artifacts only** in the first iteration.
- No signed release build, keystore creation, store upload, beta distribution, tagging, or production deployment.
- No secrets are required for the debug build path.
- `apps/*/android/local.properties` must remain ignored and must never be committed.

## Decisions needed before implementation

1. Are you willing to use GitHub Actions, and do you have a GitHub account?
2. Should the repository be **public** (free standard runners, but source becomes public) or **private** (included monthly allowance; source stays private)?
3. May I initialize Git and add a `.github/workflows/android-debug.yml` workflow file in a **separate prepared copy** or in the workspace? This is the only project-config change required.
4. May I push the repository to GitHub once you confirm the remote and visibility? You previously required explicit approval before any commit or push.
5. Should the first run be manual (`workflow_dispatch`) only? Recommended yes, to avoid surprise usage.
6. Confirm that no credentials, keystores, service-account JSON, or sensitive `local.properties` content should be included in the repository.

## Alternatives considered

| Option | Verdict |
| --- | --- |
| Resize EC2 to 4 vCPU / 16 GiB / 50 GiB | Rejected as unaffordable. |
| Local low-memory build with heap override | Still blocked by only ~1.3 GiB free disk and repeated Gradle cache growth; would also risk forbidden cache deletion. |
| Windows PC | Not needed; Flutter Android builds work on Linux. |
| Codemagic | Possible Git-based alternative, but requires a repository and has free-tier limits; GitHub Actions is simpler and has no Windows requirement. |
| GitHub Actions | **Recommended**: no local RAM/disk pressure, no Windows, no paid EC2 upgrade. |

## Preserved baseline

- Verified toolchain: Flutter 3.50.1 stable, Dart 3.14.0, JDK 21, Android SDK 37.0.0/build-tools 37.0.0.
- `flutter analyze` is clean.
- Per-app smoke tests passed.
- Root `flutter test` fails only because there is no root `test/` directory; the proposed workflow accounts for this.
- 266 source/config files were previously verified by SHA-256 with zero mismatches.

## Skills used

- `flutter-ci-cd`: provider-neutral CI/CD, quality gates, cache rules, artifact/secret separation, no publication without explicit authorization.
- `flutter-build-release`: reproducible artifact rules, explicit environments, secret preservation, and authorization boundary before signing or publishing.

## Local preparation status

- Git was initialized on branch `main`.
- `.gitignore` was intentionally updated to also ignore nested `android/local.properties`, Android key files, JKS, and keystore files.
- `.github/workflows/android-debug.yml` was created with pinned third-party actions, `permissions: contents: read`, manual + pull-request triggers, validation gates, a two-app build matrix, a CI-only Gradle/Kotlin heap override, and 7-day debug APK artifacts.
- Generated Freezed/JSON serializers and Flutter/native plugin scaffolding were force-added because the existing ignore rules would otherwise omit files required by local analysis and tests.
- A local commit was created. No push has been made.
- Awaiting the private GitHub repository URL and confirmation that Git HTTPS/SSH credentials are available on this host before pushing.
