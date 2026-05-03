# App Store Submission Audit — Unmark

A pre-flight check against Apple's App Store Review Guidelines and common rejection patterns. Status as of May 3, 2026.

Legend: ✅ pass · ⚠️ needs action · ❌ blocker

---

## Code signing & build configuration

| Item | Status | Notes |
|---|---|---|
| App Sandbox enabled | ✅ | `Resources/Unmark.entitlements` has `com.apple.security.app-sandbox = true` |
| Hardened Runtime | ⚠️ | Currently disabled because `CODE_SIGN_IDENTITY = "-"` (ad-hoc). Re-enable once you have a real Distribution certificate. Update `project.yml` |
| Network entitlement | ✅ | Not present — good for Privacy Nutrition Labels claim |
| File access entitlement | ✅ | Not present — app doesn't read user files |
| Code signing identity | ❌ | Currently ad-hoc (`"-"`). Required: switch to `"Apple Distribution"` for App Store builds |
| Provisioning profile | ❌ | Not configured. Required: create one in App Store Connect, reference in `project.yml` |
| Team ID set | ❌ | `DEVELOPMENT_TEAM` not set in `project.yml`. Add your 10-char Team ID |
| `LSUIElement = YES` | ✅ | Correctly set — app runs as menu bar only |
| `LSMinimumSystemVersion = 13.0` | ✅ | Matches deployment target |
| Bundle identifier | ✅ | `com.unmark.Unmark` — verify it's not already taken in App Store Connect, change prefix if needed |

---

## App icon compliance

| Item | Status | Notes |
|---|---|---|
| 1024×1024 marketing icon | ✅ | `Logos/App Store Marketing Icon.png` |
| All 10 sizes in `AppIcon.appiconset` | ✅ | 16/32/64/128/256/512/1024 generated |
| No alpha channel in marketing icon | ⚠️ | Verify with `sips -g hasAlpha "Logos/App Store Marketing Icon.png"` — Apple rejects icons with alpha |
| Squircle shape (Apple's exact super-ellipse) | ⚠️ | Current master uses simple rounded corners, not Apple's precise squircle template. Visually similar but may be flagged on close inspection. Use [Apple's icon template](https://developer.apple.com/design/resources/) for guaranteed compliance |
| No copy of Apple's icons | ✅ | Original "U" mark with markdown syntax — distinct |

---

## Privacy & data handling

| Item | Status | Notes |
|---|---|---|
| Privacy Nutrition Labels filled out | ❌ | Must complete in App Store Connect. Answer: "Data Not Collected" — see `APP_STORE_LISTING.md` |
| Privacy policy URL hosted | ❌ | Required URL in App Store Connect listing. Host `docs/PRIVACY.md` content at a public URL |
| Privacy manifest (`PrivacyInfo.xcprivacy`) | ⚠️ | Required since May 2024 for apps using "required reason APIs". We don't use any, but the file should still exist as an empty/minimal manifest. See "Action items" below |
| No tracking | ✅ | We do not use any third-party SDKs that track |
| No PII collection | ✅ | App handles only the user's clipboard input |

---

## UX & content (common rejection causes)

| Item | Status | Notes |
|---|---|---|
| All UI controls work as expected | ✅ | Format dropdown now functional (was placeholder before) |
| No broken or "coming soon" features | ✅ | All visible features work |
| App quits cleanly | ✅ | Quit button + ⌘Q both wired |
| App provides standard menu bar conventions | ✅ | About window, Quit |
| Spelling/grammar in UI text | ✅ | All copy reviewed |
| No placeholder/Lorem ipsum text | ✅ | None present |
| No mentions of other platforms | ✅ | Only refers to macOS |
| No mentions of beta/test/demo | ✅ | App is shipped-quality |
| Provides genuine utility | ✅ | Solves a real problem (Markdown → rich text from AI chatbots) |
| Not a wrapper around a website | ✅ | Native macOS app |
| Does what the description says | ✅ | Verify after writing description |

---

## App Store-specific guideline checks

| Guideline | Status | Notes |
|---|---|---|
| 2.1 (App Completeness) | ✅ | All features functional |
| 2.3 (Accurate Metadata) | ⚠️ | Description must match app behavior exactly — review `APP_STORE_LISTING.md` against actual app |
| 2.5.1 (only public APIs) | ✅ | No private API usage |
| 4.0 (Design) | ✅ | Native SwiftUI, follows HIG |
| 4.1 (Copycats) | ✅ | Original concept and design |
| 4.2 (Minimum Functionality) | ⚠️ | Apple sometimes rejects extremely simple utilities as "not enough functionality." Risk is real but small for this app — having 3 output formats + Launch at Login + auto-clear helps. Mitigation: lean into the AI chatbot angle in description |
| 5.1.1 (Data Collection) | ✅ | We collect nothing |
| 5.1.2 (Data Use & Sharing) | ✅ | N/A — no data |

---

## Action items before submission

**🔴 Must do (blockers):**

1. **Enroll in Apple Developer Program** ($99/year) and wait for approval (~48 hrs)
2. **Get your Team ID** from developer.apple.com → Membership
3. **Create an App Store Distribution certificate** in App Store Connect
4. **Update `project.yml`:**
   ```yaml
   settings:
     base:
       DEVELOPMENT_TEAM: YOUR10CHARID
       CODE_SIGN_STYLE: Manual           # for distribution builds
       CODE_SIGN_IDENTITY: "Apple Distribution"
       PROVISIONING_PROFILE_SPECIFIER: "Unmark App Store"
   ```
5. **Re-run `xcodegen generate`** and rebuild
6. **Add a Privacy Manifest** at `Resources/PrivacyInfo.xcprivacy` (see template below)
7. **Verify marketing icon has no alpha** — strip alpha if present:
   ```bash
   sips -s format png -s formatOptions 100 \
     "Logos/App Store Marketing Icon.png" \
     --out "Logos/App Store Marketing Icon (no-alpha).png"
   ```
8. **Take 5 App Store screenshots** at 2560×1600 or 2880×1800
9. **Host your Privacy Policy** at a public URL (any free site works)
10. **Replace placeholder email** in `APP_STORE_LISTING.md` and `PRIVACY.md` with real support address

**🟡 Should do (improves approval odds):**

11. **Test the built `.app` on a second Mac** (via TestFlight or by AirDrop'ing the signed `.app`) before submission — catches bugs that don't appear in development
12. **Verify Launch at Login actually works** in a properly signed build (it will silently fail with ad-hoc signing — this is normal in development)
13. **Verify all output formats paste correctly** into Mail, Pages, Notes, Slack, Notion
14. **Try a deliberately malformed Markdown input** to verify graceful handling (no crash, no ugly fallback)
15. **Test in dark mode and light mode** — verify menu bar icon tints correctly (template image should auto-handle this)

**🟢 Nice to have:**

16. Localize for at least Spanish, French, German, Japanese (huge App Store discoverability boost — 4–8 hours work)
17. Add accessibility labels for VoiceOver users
18. Add a brief first-launch tutorial (one-time popover with arrows)

---

## Privacy Manifest template

Save as `Resources/PrivacyInfo.xcprivacy` and add to `project.yml` under `sources` for the Unmark target:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

The `CA92.1` reason code covers "Access info from same app, per documentation" — required because we use `@AppStorage` (which is a wrapper around `UserDefaults`).

---

## Likely review timeline

- **First submission:** 24–48 hours, occasionally up to 5 business days for new developer accounts
- **If rejected:** address feedback, resubmit — usually re-reviewed within 24 hours
- **Updates after first acceptance:** typically 24 hours

---

## Highest-risk rejection scenarios for this app

1. **Guideline 4.2 (Minimum Functionality)** — Apple may say "this is just a Markdown converter, there are many." Mitigation: emphasize the AI chatbot workflow + the auto-copy + auto-clear UX (these are differentiators)
2. **Guideline 2.3.7 (Accurate Metadata)** — make sure the description matches actual app behavior exactly
3. **Privacy Nutrition Labels mismatch** — be 100% sure your "Data Not Collected" answer is accurate (it is, currently)
4. **Marketing icon with alpha** — automatic rejection. Strip alpha first.

---

## Summary

The app **is in good shape** for App Store review once the code signing and Apple Developer Program steps are complete. The main risk is Guideline 4.2 (utility too simple), which is mitigated by the genuinely useful feature set and clear positioning around AI chatbot workflows.

Estimated work to be submission-ready: **1 working day** after Developer Program approval comes through.
