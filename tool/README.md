# Google Play Release Automation Tool

An automated, native Dart release script that:
1. **Increments version/build numbers** in `pubspec.yaml`.
2. **Builds a release Android App Bundle (`.aab`)** via `flutter build appbundle --release`.
3. **Uploads and commits the release** to Google Play Console (Internal, Closed, or Production track) with **real-time progress, upload speed, and ETA tracking** via the Google Play Android Developer API.

---

## Quick Start (in this project)

### 1. Place your Service Account JSON Key
Save your downloaded Google Cloud Service Account JSON key as:
```text
android/play-service-account.json
```
*(This path is already configured in `.gitignore` so your private key will never be committed to version control).*

### 2. Test with a Dry Run
```powershell
dart run tool/release.dart --dry-run
```

### 3. Deploy to Google Play (Internal Testing Track)
```powershell
dart run tool/release.dart
```

---

## Common Release Commands

| Goal | Command |
|---|---|
| **Standard build bump to Internal track** (e.g. `1.0.0+1` $\rightarrow$ `1.0.0+2`) | `dart run tool/release.dart` |
| **Patch release to Production** (e.g. `1.0.0+1` $\rightarrow$ `1.0.1+2`) | `dart run tool/release.dart --bump=patch --track=production` |
| **Minor release with release notes** (e.g. `1.0.0+1` $\rightarrow$ `1.1.0+2`) | `dart run tool/release.dart --bump=minor --notes="New store search & filter features"` |
| **Dry run** (simulates everything without touching files or uploading) | `dart run tool/release.dart --dry-run` |
| **Only build & increment version** (skip upload) | `dart run tool/release.dart --skip-upload` |
| **Upload existing `.aab`** (skip rebuild) | `dart run tool/release.dart --skip-build` |
| **Upload as draft** | `dart run tool/release.dart --draft` |

---

## CLI Options Reference

| Flag | Default | Description |
|---|---|---|
| `--track=<name>` | `internal` | Target track: `internal`, `alpha`, `beta`, or `production` |
| `--bump=<type>` | `build` | Version bump type: `build`, `patch`, `minor`, `major`, or `none` |
| `--version=<x.y.z+n>` | *(auto)* | Specify an exact version string (e.g. `--version=1.2.0+15`) |
| `--notes="<text>"` | `'Bug fixes...'` | Release notes displayed in Play Console |
| `--key=<path>` | *(auto)* | Custom path to the Service Account JSON key |
| `--package-name=<id>` | *(auto)* | Override package name (auto-detected from `build.gradle.kts`) |
| `--dry-run` | `false` | Run simulation without modifying `pubspec.yaml` or uploading |
| `--skip-build` | `false` | Upload existing `.aab` without running `flutter build` |
| `--skip-upload` | `false` | Bump version and build `.aab` without uploading |
| `--draft` | `false` | Create a draft release in Play Console instead of publishing |
| `-h, --help` | - | Display help menu |

---

## How to Recreate This in ANY Other Flutter Project (5-Minute Recipe)

You can replicate this exact automated pipeline in any Flutter app with 4 quick steps:

### Step 1: Add dev dependencies to `pubspec.yaml`
In your new project's `pubspec.yaml`, add `googleapis` and `googleapis_auth` under `dev_dependencies`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  googleapis: ^17.0.0
  googleapis_auth: ^2.3.3
```
Then run:
```powershell
flutter pub get
```
*(Note: Because these are `dev_dependencies`, they do NOT increase the size of your production mobile app).*

### Step 2: Copy `tool/release.dart`
Copy the file `tool/release.dart` into your new project's `tool/` directory.

The script is 100% self-contained:
* It auto-detects the project root.
* It auto-detects `applicationId` / `namespace` from either Kotlin DSL (`build.gradle.kts`) or Groovy (`build.gradle`).
* It automatically finds the Service Account JSON in standard locations (`android/play-service-account.json` or `play-service-account.json`).

### Step 3: Guard your credentials in `.gitignore`
Add these lines to the new project's `.gitignore`:
```gitignore
# Google Play credentials
*service-account*.json
*play-service-account*.json
secrets/
```

### Step 4: Drop in the Service Account Key & Test
1. Place `play-service-account.json` into the `android/` directory of the new project.
2. Verify with:
   ```powershell
   dart run tool/release.dart --dry-run
   ```
3. Run your first automated deployment:
   ```powershell
   dart run tool/release.dart --track=internal
   ```

---

## How to Generate Google Play Service Account Credentials

If you need to set up API access for a new Google Play developer account:

1. **Google Cloud Console**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/).
   - Enable the **Google Play Android Developer API**.
   - Navigate to **IAM & Admin** > **Service Accounts** > **Create Service Account**.
   - Create the service account and note its email (e.g. `deployer@my-project.iam.gserviceaccount.com`).
   - Go to the **Keys** tab > **Add Key** > **Create new key** > **JSON**.
   - Download the file and save it as `android/play-service-account.json`.

2. **Google Play Console**:
   - Go to [Google Play Console](https://play.google.com/console) > **Users and permissions**.
   - Click **Invite new users** and paste the Service Account email.
   - Under **App permissions**, select your app.
   - Under **Releases**, enable:
     - *Manage testing tracks (Edit release tracks, publish releases)*
     - *Manage production releases* (if deploying to production)
   - Click **Apply** and **Invite user** (activates immediately).

---

## Troubleshooting & Important Notes

> [!IMPORTANT]
> **First AAB Must Be Uploaded Manually**:
> Google Play's API requires that the **very first `.aab`** for a new app package ID be uploaded manually once via the web Play Console UI to set up signing and store metadata. After the initial build is uploaded by hand, all subsequent releases can be automated via this tool.

> [!TIP]
> **App Signing Keystore**:
> Ensure release signing is configured in `android/app/build.gradle.kts` (or `build.gradle`) pointing to your `.jks` keystore and `key.properties`. If signing is not configured, `flutter build appbundle --release` will produce an unsigned build that Google Play will reject.
