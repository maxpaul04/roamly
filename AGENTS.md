# GEMINI.md — Project Instructions for Roamly

## Context

Roamly is a solo university project (Programming II course) — a Flutter/Dart
social travel logging app, pitched as "Letterboxd for cities." One developer,
no team. Do not suggest team workflows, PR review processes, or
multi-contributor git strategies. Do not phrase suggestions as "you and your
team" — address a single developer.

Slogans (for reference, not to be touched by code changes):
- "Log your journey. Explore theirs." (official)
- "See the world through your friends." (pitch hook)

## Architecture

- **Local persistence:** currently SQFlite, chosen because I already know
  SQL (NoSQL is only conceptually familiar, not practically). The database
  decision is not fully closed — Firestore/Firebase Storage is still on the
  table and we'll decide for real once we get to that point in the project.
  Don't assume SQFlite-only when reasoning about future features; just
  don't start building Firestore integration unprompted.
- **Auth:** Firebase Auth *is* used (it's course material for Session 6/7),
  independent of whatever the final data-storage decision ends up being.
  The user's UID can be used as a local key.
- **Friends/social data:** hardcoded mock data — either a JSON asset or Dart
  classes. Not fetched from any backend right now. Don't propose live
  friend systems, invites, or social backend features unless asked.
- **Layering:** keep a service/repository layer between UI and the database,
  e.g. `services/city_repository.dart`. This is what keeps the eventual
  storage decision (SQFlite vs. Firestore) swappable without touching UI
  code — treat this as the actual point of that layer.

## Feature scope (MoSCoW — already prioritized)

Must-have, in scope for core implementation:
- City logging: ratings, reviews, photos
- Visited-country map with colored pins
- Friend comparison map (against mock friend data)
- Friend activity feed (mock data)
- Proximity-based recommendations
- Personal stats: cities / countries / continents visited
- Wishlist

If I ask for something outside this list, treat it as a genuine feature
request, not a scope violation — the list above is what's locked in, not an
exhaustive ceiling.

## Working style

- I'm a Business Informatics student, not a professional Flutter dev.
  Explain *why* behind non-obvious Dart/Flutter idioms (e.g. why a
  `FutureBuilder` vs. a `StreamBuilder`, why `const` matters here) — don't
  just hand over code silently. But don't over-explain basic syntax.
- Prefer direct fixes/answers over Socratic back-and-forth unless I ask to
  be walked through something conceptually.
- Course-level abstraction is fine; this doesn't need production-grade
  robustness (retry logic, offline queues, etc.) unless the assignment
  specifically calls for it.
- i prefer to work iteratively, and not by copy-pasting entire code blocks, i want to go make something work on a small scale before moving on to the bigger issues
- when you fix some of my code inside your chat, do not past the entire file again, only show the relevant section

## Do NOT

- Do not start implementing Firestore/Cloud Storage integration on your own
  initiative — that decision gets made explicitly when we get there.
- Do not build real authentication/invite flows for friends.
- Do not restructure the repository layer "for scalability" beyond the
  service/repository split already agreed on.
- Do not assume a team context anywhere in generated code comments, commit
  message suggestions, or docs.