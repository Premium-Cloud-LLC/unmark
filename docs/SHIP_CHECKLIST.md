# Unmark Ship Checklist — Free Direct Download

A concrete, ordered list of every step required to make Unmark downloadable from your own URL onto any Mac in the world. ~5 days, $99 total cost (Apple Developer Program).

---

## Day 1 — Today (15 min, then wait 24-48 hrs)

### [ ] 1. Enroll in Apple Developer Program
- Go to https://developer.apple.com/programs/enroll/
- $99 USD/year, individual enrollment is fine for a free utility
- You will get an email when approved (typically 24-48 hrs)

**Why required:** without a Developer ID, your DMG triggers macOS Gatekeeper warnings. Most users will not bypass them — they'll just delete the file.

---

## Day 2 — Set up channels (30 min)

### [ ] 2. Create a public GitHub repository
- Name it `unmark` (or whatever)
- Add a README that says what the app is + a link to your future Releases page

### [ ] 3. Push the project to GitHub
```bash
cd /Users/shanebailey/VSProjects/unmark
git init
git add -A
git commit -m "Initial commit: Unmark v1.0"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/unmark.git
git push -u origin main
```

### [ ] 4. Decide on a domain (optional, $20/year)
- Cleanest: `unmark.app` from any registrar (Cloudflare, Hover, Namecheap)
- Free alternative: `https://YOUR_USERNAME.github.io/unmark/` via GitHub Pages

### [ ] 5. Pick where to host the privacy policy
- Easiest: GitHub Pages — it serves any markdown file automatically
- Just enable Pages in repo Settings → Pages → main branch → /docs folder

---

## Day 3 — Prep launch materials (1 hr)

### [ ] 6. Take 3-5 nice screenshots
- Screenshot the popover with sample Markdown showing the conversion
- Screenshot the About window
- Screenshot the popover side-by-side with a paste into Mail or Pages
- Save in `docs/screenshots/` for the README and landing page

### [ ] 7. Fill in placeholder text
- In `docs/PRIVACY.md` — replace `[your-email@example.com]` with your real support email
- In `docs/index.html` (the landing page) — update download URL once you have a GitHub Release URL

### [ ] 8. Draft launch announcement
- Tweet thread with screenshots
- Hacker News "Show HN" post
- Product Hunt scheduling (optional — can launch any day)
- r/macapps subreddit post (allowed for free apps)
- Don't post yet

---

## Day 4 — Apple approves; certificate setup (1 hr)

### [ ] 9. Note your Team ID
- Log into https://developer.apple.com/account/
- Click Membership in the sidebar
- Your **Team ID** is a 10-character alphanumeric string. Save it.

### [ ] 10. Create a Developer ID Application certificate
- Click Certificates, Identifiers & Profiles
- Click `+` (top right of Certificates)
- Choose **Developer ID Application** (NOT "Developer ID Installer", NOT "Apple Distribution")
- Click Continue
- Generate a Certificate Signing Request (CSR):
  1. Open Keychain Access app
  2. Menu: Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
  3. Enter your email and name; choose "Saved to disk"
  4. Save the `.certSigningRequest` file
- Upload that CSR to Apple's portal
- Download the resulting `.cer` file
- Double-click to install in Keychain

### [ ] 11. Create an app-specific password for notarytool
- Go to https://appleid.apple.com → Sign-In and Security → App-Specific Passwords
- Generate one labeled "notarytool"
- Save the password somewhere safe — you only see it once

### [ ] 12. Store the credentials so notarytool can use them
```bash
xcrun notarytool store-credentials "AC_NOTARYTOOL" \
    --apple-id "your-apple-id@example.com" \
    --team-id "YOUR10CHARID" \
    --password "your-app-specific-password-from-step-11"
```
(One-time setup. The script will reference this profile name automatically.)

### [ ] 13. Update `project.yml` with your Team ID
- Open `project.yml`
- Find the "PRODUCTION signing" comment block under `targets.Unmark.settings.base`
- Comment out the two `CODE_SIGN_STYLE: Automatic` / `CODE_SIGN_IDENTITY: "-"` lines
- Uncomment the three production lines and replace `YOUR10CHARID` with your actual Team ID
- Save

### [ ] 14. Regenerate the Xcode project
```bash
xcodegen generate
```

---

## Day 5 — Build, notarize, ship (1 hr active + ~30 min Apple wait time)

### [ ] 15. Update `scripts/make-dmg.sh` with your name + Team ID
- Open `scripts/make-dmg.sh`
- Update the `DEVELOPER_ID` line:
  ```bash
  DEVELOPER_ID="Developer ID Application: Your Real Name (YOUR10CHARID)"
  ```
- Update the `teamID` value inside the `ExportOptions.plist` block

### [ ] 16. Install create-dmg if not already
```bash
brew install create-dmg
```

### [ ] 17. Run the build pipeline
```bash
./scripts/make-dmg.sh
```

You'll see output like:
- "==> Archiving Release build…" (~30 sec)
- "==> Exporting signed .app…" (~10 sec)
- "==> Submitting .app to Apple notary service…" (5–15 min — Apple is scanning for malware)
- "==> Stapling notarization ticket to .app…"
- "==> Building DMG…"
- "==> Submitting DMG to Apple notary service…" (another 5–15 min)
- "==> Stapling DMG…"
- "Done! Distributable DMG ready at: dist/Unmark.dmg"

### [ ] 18. Test the DMG on a clean Mac
- AirDrop the DMG to a friend's Mac, OR
- Create a new user account on your Mac, log in as that user, copy the DMG, mount it
- The user should NOT see any Gatekeeper warning. If they do, something went wrong with notarization.

### [ ] 19. Create a GitHub Release
Either via web UI (drag the DMG into the release form) or CLI:
```bash
gh auth login   # one-time, if not already
gh release create v1.0.0 dist/Unmark.dmg \
  --title "Unmark 1.0" \
  --notes "Initial public release. See README."
```

Your direct download URL is now:
```
https://github.com/YOUR_USERNAME/unmark/releases/latest/download/Unmark.dmg
```

### [ ] 20. Deploy your landing page
If using GitHub Pages:
- Repo Settings → Pages → main branch, `/docs` folder, save
- Your site appears at `https://YOUR_USERNAME.github.io/unmark/`
- Update the download button in `docs/index.html` to point to your GitHub Release URL

### [ ] 21. Update `docs/PRIVACY.md`
- Replace `[your-email@example.com]` with real support email
- This will auto-publish at `https://YOUR_USERNAME.github.io/unmark/PRIVACY.html` once GitHub Pages is on

### [ ] 22. SHIP IT
- Tweet the announcement with screenshots
- Submit to Product Hunt (the launch slot is yours from 12am PT)
- Post "Show HN" with a clear title: `Show HN: Unmark – paste Markdown, copy rich text on macOS`
- Post on r/macapps subreddit
- Email your friends

---

## After launch (week 2+)

### [ ] 23. Monitor download counts
- GitHub Releases shows download count per asset
- Watch for issues filed in your repo

### [ ] 24. Decide about auto-updates
**Without Sparkle:** users have to manually re-download for each version. Fine for a small free app.
**With Sparkle:** users get a "New version available — install?" prompt automatically. ~3-5 hours of integration work.

When you're ready: tell me "set up Sparkle" and I'll wire it in.

### [ ] 25. Plan v1.1
- Watch what users ask for
- Common asks for utilities like this: keyboard shortcut to invoke (e.g., `⌃⌥⌘V`), a small history of recent conversions, custom output styles

---

## Common gotchas

- **"Code signing identity not found"** during build → certificate isn't installed in Keychain, or the name in `project.yml` doesn't match exactly. Run `security find-identity -v -p codesigning` to see what's there.
- **Notary submission rejected** → run `xcrun notarytool log <submission-id> --keychain-profile AC_NOTARYTOOL` to see why. Most commonly it's a hardened runtime entitlement issue.
- **DMG mounts but app shows "damaged" warning** → notarization was skipped or stapling failed. Re-run the script; the script's last step should be `stapler validate`.
- **App opens but immediately quits on a different Mac** → unsigned dependency. Verify with `codesign --verify --deep --strict --verbose=2 path/to/Unmark.app`.

---

## Total cost

| Item | Cost |
|---|---|
| Apple Developer Program (1 year) | $99 |
| Domain (optional) | $20/year |
| Hosting | $0 (GitHub) |
| Update mechanism (optional) | $0 (Sparkle is free) |
| **Total to launch** | **$99–119** |

After year 1, only the $99 Apple renewal is required to continue distributing. If you stop renewing, your existing DMGs continue to work but you can't ship updates.
