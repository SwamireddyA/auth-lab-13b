# In-Class Activity 13B — Reflection & Evidence

**Name:** Swamireddy Ailuri
**Activity:** In-Class Activity #13B — Firebase Authentication in Flutter
**Test date:** 2026-11-10
**Platform/device:** Android emulator (Medium Phone, sdk gphone16k x86_64), debug build
**Repository:** https://github.com/SwamireddyA/auth-lab-13b

> Fill every [bracket] with what you actually observed. Mark untested items as planned, not passed.

---

## 1. Test Evidence

| # | Test action | Expected | Observed | Pass/Fail |
|---|---|---|---|---|
| 1 | Register new test account (test13b@example.com) | Profile shows test email; user appears in Firebase Console → Users | Profile showed "Signed in as test13b@example.com" [confirm Users tab yourself] | Pass |
| 2 | Sign out → sign in with same account | Profile shows email | Covered by test 9 | Pass |
| 3 | Sign in with an invalid email | Inline "Enter a valid email" — no request sent | Red inline "Enter a valid email, like name@example.com." | Pass |
| 4 | Register with 5-char password | Inline "at least 6 characters" | [ ] | [ ] |
| 5 | Sign in with wrong password | Banner "Email or password is incorrect." (no raw exception) | Same as test 8 | Pass |
| 6 | Tap Create account | Spinner shown, fields/button disabled until response | Fields greyed out, spinner in button | Pass |
| 7 | Change password | Dialog closes + snackbar "Password updated successfully." | Dialog closed with no error (snackbar not captured in screenshot) | Pass |
| 8 | Sign out → sign in with OLD password | Fails with safe message | Banner "Email or password is incorrect." — no raw exception | Pass |
| 9 | Sign in with NEW password | Profile shown | Profile with test13b@example.com | Pass |
| 10 | Sign out | Sign-in screen shown; back button does not return to profile | Sign-in screen shown [check Back button yourself] | Pass |
| 11 | Close app fully while signed in, reopen | Profile shown without sign-in (session restored) | [ ] | [ ] |
| 12 | Requires-recent-login | See §1a | [ ] | [ ] |

**Screenshot 1 — [caption: action, expected, observed, pass/fail]**
[insert image]

*(repeat per screenshot; redact passwords)*

### 1a. Requires-recent-login recovery
**If triggered** (e.g. sign in, wait >5 min or so, then change password): screenshot the "Confirm it's you" dialog and the success snackbar.
**If not triggered — label as TEST PLAN, not a pass:** `AuthService.updatePassword` maps `requires-recent-login` to `AuthFailure(requiresRecentLogin: true)`. The dialog then reveals a "Current password" field; on submit, `reauthenticateAndUpdate` builds an `EmailAuthProvider.credential`, calls `reauthenticateWithCredential`, and retries `updatePassword`.

---

## 2. AI Comparison  *(do this yourself — the grade is for YOUR judgment)*
**Track:** [Undergraduate / Graduate — whichever your instructor assigned]

**My prediction (written before asking AI):**
[Your flow sketch in 3–5 lines + two tests you expected to pass]

**AI tool & date:** [e.g. Gemini free tier, 2026-11-10]
**Summary of its suggestions (my words):** [ ]

**Compare / verify / decide:**
- Useful idea I kept: [ ]
- Claim I checked: [ ] → Source: https://firebase.google.com/docs/auth/flutter/manage-users → Result: [ ]
- What I changed or rejected and why: [ ]

*(Graduate track extra: one assumption/trade-off the AI missed, one unsupported claim, and the revised design/test you defend with the primary source.)*

**Disclosure:** [List all AI assistance used, including for code scaffolding.]

---

## 3. Reflection Prompts
*(Decision · Trade-off · Risk · Evidence for each)*

**P1 Expectation vs obtained:** [ ]
**P1 follow-up (root cause + lesson):** [ ]
**P2 Debug evidence (one real issue + test that confirmed fix):** [ ]
**P2 follow-up (alternative fix rejected):** [ ]
**P3 Improvement plan:** [ ]
**P4 Security vs UX:** [Starting point: one generic message for wrong password and unknown user — safer (no account enumeration) but less specific for the user.]
**P5 Auth, authorization, prior learning:** [Starting point: AuthGate is the same StreamBuilder pattern from In-Class 12, but on `authStateChanges()` instead of a Firestore query. UI gating is not security — Firestore rules like `allow read, write: if request.auth != null && request.auth.uid == userId;` on `users/{userId}` are what actually enforce access.]
**P6 Scale (10,000 users):** [ ]

---

## Sources
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/auth/flutter/start
- https://firebase.google.com/docs/auth/flutter/manage-users
- https://docs.flutter.dev/cookbook/forms/validation
