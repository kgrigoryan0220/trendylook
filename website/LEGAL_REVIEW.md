# Legal texts: consistency review

**Documents reviewed:** `src/content/legal/privacy.md` (Privacy Policy) and `src/content/legal/terms.md` (Terms of
Service), both "Last updated: September 10, 2026". Both are word-for-word copies of `legal/PRIVACY_POLICY.md` and
`legal/TERMS_OF_SERVICE.md`; **no wording was changed**.

**Checked against:** the app facts in the brief, the site's `src/config.ts`, and (where noted) the app code in this
repository.

**Status key:** **OK** = covered and consistent · **MISSING** = not covered · **CONTRADICTS** = conflicts with the facts
or with the other document · **UNCLEAR** = covered, but vague or hedged.

---

## Summary: what to fix first

1. **CONTRADICTS: deleting a single check.** The policy implies individually deleted checks are deleted. In the app it is a
   soft delete (`soft_delete_check` sets `deleted_at`): the row and the photo stay until the account is deleted.
2. **Resolved: contact email.** The site's `SUPPORT_EMAIL` is now `trendylook2026@outlook.com`, the same as in both
   documents.
3. **Template leftovers** visible to users: the "(Optional: If you prefer arbitration…)" note in Terms §17.3 and the
   internal "must match this Policy" note in Privacy §16.
4. **MISSING: what happens after cancellation** (Pro stays until the end of the paid period, then the account returns to
   the free tier).
5. **UNCLEAR: "if enabled" hedges** on PostHog and Sentry, while the brief lists both as used. The PostHog region (EU)
   isn't stated, and the legal basis for analytics (consent vs legitimate interest) is left open.
6. **MISSING: GDPR representative.** The controller is an individual in Georgia (outside the EU/UK) offering the app to
   EU/UK users. Check whether an EU (Art. 27 GDPR) and UK representative is needed.
7. **CONTRADICTS (minor): minimum age.** Privacy says 13 (16 in the EEA). Terms say 13 (16 in the EEA/UK). The product
   targets 16–30.

---

## 1. Every data type and third-party service is disclosed (purpose and where the data goes)

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Sign in with Apple / Google Sign-In via Supabase Auth | **OK** | Privacy §3.1: "Email address and user ID when you sign in with Apple or Google"; §7: "**Supabase** \| Authentication, database, file storage, serverless functions". Terms §4.1: "You may sign in using **Sign in with Apple** or **Google Sign-In**." | None. |
| Outfit photos in Supabase Storage | **OK** | Privacy §5.1: "The photo is uploaded to our **private, access-controlled storage** (Supabase Storage, bucket `look-photos`)." | Optional: drop the internal bucket name `look-photos`. Users don't need it. |
| Check history in Supabase Postgres | **OK** | Privacy §3.2: "Records of your past outfit checks (date, score, stored image reference)"; §7 Supabase "database". | None. |
| Photos sent to OpenAI (GPT-4o Vision) | **OK** | Privacy §5.1: "sends the image to **OpenAI**'s API for automated outfit analysis"; §7: "**OpenAI** \| AI vision analysis of outfit photos". | Optional: name the model ("GPT-4o") or say "OpenAI vision models", so a model change doesn't require an update. |
| RevenueCat, App Store / Google Play billing | **OK** | Privacy §3.3: "Subscription and transaction identifiers from Apple/Google processed through RevenueCat"; §7 RevenueCat, Apple, Google. | None. |
| Promo codes, restore purchases | **OK** | Privacy §3.1 "Promo codes"; §5: "apply promo codes, restore purchases". Terms §5.3 "Restore purchases", §5.4 promo codes. | None. |
| PostHog analytics (EU region) | **UNCLEAR** | Privacy §3.3: "(via PostHog, when enabled)"; §7: "**PostHog** \| Product analytics (if enabled)". | Remove "when enabled" / "if enabled". PostHog is in use. Add "hosted in the EU (PostHog EU Cloud)". |
| Sentry crash reporting | **UNCLEAR** | Privacy §3.3: "(via Sentry, when enabled)"; §7: "**Sentry** \| Crash reporting (if enabled)". | Remove the hedge and state the Sentry region (US by default, unless you chose Sentry's EU region). |
| Where data goes (per provider) | **UNCLEAR** | Privacy §8: "Our service providers may process data in the **United States**, the **European Union**, and other countries." | List the location per provider: Supabase (EU, Frankfurt `eu-central-1` per the repo README), PostHog (EU), OpenAI (US), RevenueCat (US), Sentry (US or EU), Apple/Google (global). |
| "Purpose" column in §3.1–3.3 | **UNCLEAR** | Privacy §3.1 table header: "\| Data \| Purpose \|", but the cells describe the data ("Email address and user ID…"), not the purpose. | Rename the column to "Details", or add the purpose per row. Purposes are listed separately in §5. |

## 2. Photo retention and what happens on account deletion

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Photo retention period | **UNCLEAR** | Privacy §9: "Outfit photos & check history \| Until you delete your account, or until deleted individually if such feature is available" | Say it plainly, e.g. "Kept until you delete the check or your account." Drop "if such feature is available": the History screen already has delete. |
| Deleting a single check | **CONTRADICTS** | Same line as above. In the app, `supabase/migrations/20261002120000_soft_delete_check_rpc.sql` only sets `deleted_at`. The check row and the photo in storage remain. | Either hard-delete the photo (and row) when a user deletes a check, or say so honestly: "Deleted checks are hidden immediately and permanently erased when you delete your account (or within X days)." |
| Account deletion | **OK** | Privacy §9: "When you delete your account (Section 11), we delete your photos from storage and remove your profile, checks, and subscription records…"; §11.1 "(cascading delete)". Terms §4.4 matches. Confirmed in code: `supabase/functions/delete-account` removes the storage files. | None. |
| Backups | **UNCLEAR** | Privacy §11.1: "Residual copies in backups may persist for a limited period." | Give a number (e.g. "up to 30 days"), matching your Supabase backup retention. |
| Data held by processors after deletion | **MISSING** | Nothing says what happens to data in PostHog, Sentry, RevenueCat or OpenAI when an account is deleted. | Add a sentence, e.g. "Analytics and crash data expire under the provider's retention (see §9); we also delete your RevenueCat customer record and PostHog person profile." (Do this in the deletion flow too.) |
| Purchase records vs "subscription records deleted" | **UNCLEAR** | Privacy §9: "Purchase records \| … (often 3–7 years for transaction records)" vs §11.1: "deletes … subscription records from our active databases". | Clarify that transaction records needed for tax/fraud are kept (by you, RevenueCat or the stores) for the stated period, while the app-side subscription status is deleted. |
| OpenAI retention | **OK** | Privacy §5.1: "OpenAI may retain API data for a limited period for abuse monitoring and service operation." | Optional: add "(currently up to 30 days)" and link OpenAI's policy. |

## 3. How to delete the account and request data deletion

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| In-app deletion | **OK** | Privacy §11.1: "**In the App:** Profile → Delete account". Terms §4.4: same. | None. |
| Deletion by email | **OK** | Privacy §11.1: "Send a deletion request from your registered email to **trendylook2026@outlook.com**. We will verify your identity and complete deletion within **30 days**." | None. Note: users who signed in with Apple's "Hide My Email" have a relay address as their "registered email". Say you will accept requests that include the account's relay address or user ID. |
| Web deletion link for Google Play | **UNCLEAR** | Privacy §16: "users can request account deletion." | Google Play requires a web link where users can request deletion without reinstalling the app. The Privacy Policy URL (`/privacy#111-account-deletion`) can serve as that link, or add a short dedicated page later. |
| How to exercise other rights (access, export, correction) | **UNCLEAR** | Privacy §11 lists the rights, but only §11.1 explains how to act on one. | Add: "To exercise any of these rights, email … We respond within one month." |

## 4. Minimum age and minors

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Minimum age stated | **OK** | Privacy §12: "not directed to children under 13 (or under 16 in the EEA where applicable)". Terms §3: "at least **13 years old** (or **16** in the EEA/UK if applicable)". | See below. |
| Consistency between documents | **CONTRADICTS** (minor) | Privacy mentions only the **EEA**. Terms say **EEA/UK**. | Use the same wording in both. |
| Fit with the target audience (16–30) | **UNCLEAR** | Both documents allow 13+ outside the EEA. | Consider a single **16+** minimum everywhere. It matches the audience, the store age rating and the marketing, and avoids the parental-consent rules for 13–15. |
| Minors 13–17 | **UNCLEAR** | Terms §3: "If you are under 18, you represent that you have permission from a parent or legal guardian." Privacy has no matching statement. | Mention it in Privacy §12 too, or drop it if you move to 16+. |

## 5. GDPR basics

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Data controller name and contact | **OK** | Privacy §1: "**Data controller:** Artur Arzumanian, Lochini str., N 3, … Tbilisi 0152, Georgia, Email: trendylook2026@outlook.com". | None. |
| EU / UK representative | **MISSING** | The controller is in Georgia (outside the EU/UK) and the app targets EU users (DE, FR, ES, IT, PT locales). | Check with counsel whether Art. 27 GDPR (and UK GDPR) requires an appointed representative. If it does, add their name and contact. |
| Legal basis | **OK / UNCLEAR** | Privacy §6 table: Contract / Legitimate interests / Consent / Legal obligation. "**Legitimate interests** \| Security, fraud prevention, analytics…" and "**Consent** \| Optional permissions (camera, gallery), and where required for analytics". | Analytics is listed under both bases. Decide which one applies and implement it (consent prompt, or legitimate interest with an opt-out). Device camera/gallery permissions are OS controls, not a GDPR legal basis. Photo processing rests on the contract. |
| User rights | **OK** | Privacy §11: access, correct, delete, export, object/restrict, withdraw consent, lodge a complaint. | Add the response time and how to exercise rights (see section 3). |
| Analytics opt-out | **UNCLEAR** | Privacy §11.3: "you may limit analytics through in-app settings (if provided) or by contacting us." | If there's no in-app toggle, delete "(if provided)" and say "by contacting us", or add a toggle. |
| International transfers (OpenAI outside the EU) | **UNCLEAR** | Privacy §8: "Where required, we use appropriate safeguards such as Standard Contractual Clauses or equivalent mechanisms." | Name the transfers explicitly: OpenAI, RevenueCat (and Sentry if US) in the United States. Name the safeguard (EU–US Data Privacy Framework where the provider is certified, otherwise SCCs). Also mention transfers to the controller in Georgia. |
| Automated processing | **OK** | Privacy §5.1: "AI output is **automated** and for entertainment / informational purposes only". | None. Scores have no legal or similarly significant effect. |

## 6. Subscription terms

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Plans | **OK** | Terms §5.2: Weekly `weekly_unlimited` 7 days, Half-year `halfyear_unlimited` 6 months. | Optional: drop the internal product IDs. Users don't need them. |
| Price shown before purchase | **OK** | Terms §5.2: "**Prices** are displayed in the App before purchase and may vary by country, currency, and platform. Taxes may apply." | None. |
| Auto-renewal | **OK** | Terms §5.3: "**Subscription automatically renews** unless auto-renew is turned off at least **24 hours** before the end of the current period." | None. |
| How to cancel | **OK** | Terms §5.3: "**iOS:** Settings → Apple ID → Subscriptions"; "**Android:** Google Play → Payments & subscriptions → Subscriptions". | Optional: current iOS wording is "Settings → [your name] → Subscriptions". |
| Refunds via Apple / Google | **OK** | Terms §5.5: "Refund requests must be submitted through the platform where you purchased (Apple App Store or Google Play)." | None. |
| What happens after cancellation | **MISSING** | Nothing says when access ends. | Add: "If you cancel, Pro access continues until the end of the current billing period, then your account returns to the free tier. Your check history stays available." |
| Free trials | **UNCLEAR** | Terms §5.4: "We may offer free trials or promotional access (including promo codes)." | The app facts list promo codes but no free trial. Fine as "may", but drop "free trials" if you don't plan any. |
| EU right of withdrawal | **UNCLEAR** | Not mentioned. | Optional: say that EU consumers' withdrawal rights for digital purchases are handled under Apple's / Google's terms. |

## 7. AI disclaimer

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Entertainment / style suggestions, not professional advice | **OK** | Terms §2: "The App is provided for **personal, non-commercial entertainment and informational purposes only**. It is **not** professional styling, image consulting, or personal shopping advice." Terms §7: "**Do not rely on the App as a substitute for professional advice.**" Privacy §5.1 matches. | None. |
| Clothes only, never body, face or weight | **OK** | Privacy §5.1: "Our AI instructions prohibit comments on weight, body type, or facial appearance." | Optional: repeat it in Terms §7, since the website promises "Zero body-shaming". |

## 8. Contact email, company name and "Last updated" date

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| Email consistent between documents | **OK** | `trendylook2026@outlook.com` in Privacy §1, §11.1, §14 and Terms §1, §4.2, §4.4, §17.1, §22. | None. |
| Email consistent with `SUPPORT_EMAIL` | **OK** (resolved) | `src/config.ts`: `SUPPORT_EMAIL = "trendylook2026@outlook.com"`. | None. If you move to a domain address later, change it in all three places. |
| Company / controller name consistent | **OK** | "Artur Arzumanian" in both documents. | Note: "Trendy Look" in the site footer (© 2026 Trendy Look) is the brand, not the legal party. That's fine. The App Store / Play seller name should match "Artur Arzumanian". |
| "Last updated" date | **OK** | Both: "**Effective date:** September 10, 2026 · **Last updated:** September 10, 2026". | Update both whenever you apply the fixes from this report. |
| Document name | **UNCLEAR** | The document is titled "Terms of Service" (and Privacy §5.1 says "see Terms of Service"), but the site navigation and page title say "Terms of Use", as the brief asked. | Pick one name and use it everywhere: the document heading, the footer link and the store listings. |
| Language | **UNCLEAR** | Terms §21: "**Language:** The English version controls in case of conflict with translations." | The app ships in 7 languages. Either provide translated documents or note that the documents are available in English only. |

## 9. Placeholders, template leftovers, broken links, features the app does not have

| Item | Status | Relevant line | Suggested fix |
|---|---|---|---|
| `[Company Name]`, lorem ipsum, bracketed placeholders | **OK** | None found. | None. |
| Arbitration drafting note | **CONTRADICTS** (template leftover) | Terms §17.3: "*(Optional: If you prefer arbitration, replace this subsection with an arbitration clause reviewed by your lawyer.)*" | Delete the note. It is shown to users on `/terms`. |
| Internal note in Google Play section | **CONTRADICTS** (template leftover) | Privacy §16: "Google Play's **Data safety** section must match this Policy." | Rewrite as a user-facing statement, e.g. "The information in our Google Play Data safety section reflects this Policy." |
| "if enabled / when enabled / if available / if provided / where configured" hedges | **UNCLEAR** | Privacy §3.3, §7, §9, §11.3, §15 ("aggregated analytics (where configured)"). | Replace them with what the app actually does today. |
| Marketing emails | **UNCLEAR** (feature not in the app) | Privacy §11.2: "We do not send promotional emails unless you opt in." | The app has no email opt-in. Either say "We do not send marketing emails" or remove §11.2. |
| Shared content | **UNCLEAR** | Terms §10: "Shared content may include your photo, score, and recommendations." | The latest app build removed the tip from the share card (commit `478c3d4`). "May include" still holds, but align it with the app (and the site copy, see TODO.md §4). |
| Broken links | **OK** | The originals contain no links. The site adds `mailto:` links for the email, links between the two documents, and in-page links for "Section 7 / 11 / 14". All of them resolve (anchors checked in the build). | None. |

---

> **Note:** This is a consistency check of the provided texts against the product facts and the website, not legal
> advice. Have a qualified lawyer review the documents before relying on them, especially the GDPR representative
> question, the analytics legal basis and the minimum-age policy.
