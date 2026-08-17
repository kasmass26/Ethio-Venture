# Product requirements

## Product overview

Ethio Venture connects founders seeking capital with investors seeking relevant
investment opportunities. It gives each audience a focused workspace while
supporting a shared discovery, matching, and conversation flow.

## Users and roles

| Role | Primary goal | Core capabilities |
| --- | --- | --- |
| Startup founder | Present a venture and find relevant investors | Manage a startup profile, upload documents, view matches, message investors |
| Investor | Find opportunities matching an investment thesis | Manage preferences, search/filter startups, review profiles, message founders |
| Administrator | Keep the platform safe and useful | Moderate content, manage reports, review platform activity |

One authenticated user has one application role. A future role-change flow must
be administrator-controlled and auditable.

## Functional requirements

### Authentication and onboarding

- Users can register, sign in, sign out, reset their password, and maintain a
  secure session through Supabase Auth.
- New users choose either the `founder` or `investor` role during onboarding.
- The app creates a base profile after successful registration and sends each
  role to its appropriate profile-completion flow.

### Startup profiles

- Founders can create, edit, preview, and publish a startup profile.
- A profile includes startup name, summary, industry, location, funding stage,
  capital sought, team information, and optional links.
- Founders can upload pitch decks and supporting documents and control whether
  each document is visible to matched investors.

### Investor profiles and preferences

- Investors can create and edit a profile containing organisation details,
  biography, location, and contact preferences.
- Investors can configure an investment thesis: industries, stages, locations,
  ticket range, and other criteria approved by the product team.

### Discovery and matching

- Investors can search and filter published startup profiles.
- The platform recommends startups and investors using compatible profile and
  preference data. Recommendations must be explainable with visible reasons.
- Users can save, dismiss, or express interest in a recommendation.
- The dashboard shows current matches and interaction history.

### Messaging, notifications, and administration

- Matched users can exchange direct messages.
- Users receive in-app notifications for new matches and messages.
- With consent, Firebase Cloud Messaging delivers push notifications.
- Administrators can review reported content and suspend or restore accounts;
  sensitive actions must be logged.

## Non-functional requirements

| Area | Requirement |
| --- | --- |
| Security | Enforce authorization in Supabase Row Level Security, not only in the Flutter UI. |
| Privacy | Collect only data needed for matching; provide clear visibility and notification controls. |
| Reliability | Handle offline, expired-session, and network-error states gracefully. |
| Performance | Paginate discovery, matches, notifications, and conversations. |
| Accessibility | Support scalable text, semantic labels, sufficient contrast, and keyboard/screen-reader navigation. |
| Observability | Record non-sensitive errors and operational events without logging credentials or private documents. |

## Success measures

Initial product metrics should include completed profiles, relevant-match views,
interest expressions, conversations started, notification delivery rate, and
time from registration to first meaningful interaction. Define metric owners
and exact event names before analytics is introduced.

## Out of scope for the initial release

Unless separately approved, the initial release does not process investments,
provide financial advice, perform investor accreditation verification, or
guarantee funding outcomes.
