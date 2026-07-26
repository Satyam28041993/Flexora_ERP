# Flexora — Project Instructions for Claude

**Read this file at the start of every session. It encodes permanent rules from
`Doc/Flexora-Master-Requirements-v1.2.md`, the single source of truth for this
project. If anything here conflicts with that document, the document wins —
flag the conflict, don't silently pick one.**

## What Flexora is

ERP + HRMS for **Flexographic Label Manufacturing**. First real implementation:
**Prakruti Graphic Pvt. Ltd. (PGPL)**, Vasai East, Maharashtra — Tenant #1.
Architected to be reusable by other label manufacturers later — not PGPL-only,
but PGPL is the concrete spec source.

Full context, workflow diagrams, QC gates, material management rules, Product
Master hierarchy, and the implementation backlog all live in
`Doc/Flexora-Master-Requirements-v1.2.md`. Re-read it before designing any
module — do not rely on memory of a summary.

## GOLDEN RULES (apply to every module, always — non-negotiable)

1. **Module-by-module build.** Never design or build a module before its stage
   is reached. When a module's stage is reached:
   a. Remind the user what was already identified for it in Section 8
      (Implementation Backlog) of the master doc.
   b. Ask for the actual current process, exceptions, and business rules.
   c. Ask for the existing company format/sheet/document for it.
   d. Ask whether an applicable ISO format exists and ask for it.
   e. Only after (a)–(d) are answered, design database → workflow → UI.
2. **Never invent business rules, formulas, or checklists** — wastage
   calculation, ink tracking logic, QC checklists, costing logic, permissions,
   etc. If it's not explicitly provided by the user, it stays an Open Question
   (Section 10 of the master doc), not a guess.
3. **ISO Documentation & Document Control is project-wide.** Before finalizing
   any official form/document/register/checklist/report/printable
   output/PDF/approval record, ask whether an approved ISO company format
   exists. Support document-control fields (Doc Title, Doc Number,
   Department, Revision No., Revision Date, Effective Date, Prepared By,
   Checked By, Approved By, Page No.) per the actual supplied format — never
   assume a layout. Maintain revision history; never destroy traceability of
   which revision a historical record was created under.
4. **CRM boundary.** Lead/Enquiry/Quotation/Negotiation/initial PO run on the
   existing Liptrack CRM (TradeIndia API) + email. Flexora does **not**
   replace this. **Flexora scope starts from confirmed Order/PO + advance
   payment received.**
5. **Revision/change control everywhere.** Artwork, product specs, shade
   cards, ISO formats — never silently overwritten; always version history.
6. **Traceability is core**, not a bolt-on report — every transaction carries
   job/customer/user/date/reference links from day one.
7. **Transaction-based inventory.** Stock quantities are never manually
   edited; every movement (receipt, issue, return, consumption, wastage,
   adjustment) is a logged transaction with reason + reference.
8. **Conflicts get flagged, not resolved silently.** If two instructions from
   the user appear contradictory, stop and ask — do not pick one.

## Technology stack — LOCKED (Section 0A of master doc)

Do not change without explicit user request.

- **Application framework:** Flutter — Android, Web, desktop-friendly web,
  tablet-responsive. One codebase across platforms.
- **Backend:** Firebase
  - Database: **Cloud Firestore** (primary operational DB)
  - Auth: **Firebase Authentication**
  - Files: **Firebase Storage** (artwork, PO, approvals, ISO docs, QC
    attachments, Shade Card evidence, employee docs, reports — Firestore
    holds metadata/references only, never large files)
  - Server logic: **Cloud Functions**, only where genuinely required
  - Notifications: **Firebase Cloud Messaging**
- **Architecture — strict layering, always:**
  `UI/Presentation → Business Logic → Services/Repositories → Firebase/Data Layer`
  - No business logic in UI widgets.
  - No screen wired directly to a Firestore collection.
  - Firestore collections are designed only after workflow → requirements →
    entities → relationships → permissions → audit requirements are all
    understood. Not "uncontrolled NoSQL structure because Firestore allows it."
- **Security:** Firebase Auth + RBAC + Firestore Security Rules + Cloud
  Functions for sensitive ops. Authorization enforced at the data layer, not
  just by hiding UI — unauthorized reads/writes must be blocked even if the
  app UI is bypassed.
- **Multi-plant readiness:** `plant_id` on all tables from day 1 (single
  plant in production today).
- **Offline:** Keep shop-floor connectivity limits in mind for
  Production/QC/Stores/Attendance, but do not build offline architecture
  prematurely — evaluate per module when reached.
- **Cost/scale discipline:** efficient Firestore queries/data structures,
  avoid unnecessary reads, redundant real-time listeners, wholesale
  collection downloads, excessive writes.
- **Code quality bar:** modular, reusable, consistent naming, proper error
  handling, loading/empty states, input validation, responsive UI, minimal
  duplication, secure Firebase access, scalable queries, logging where
  required.
- **UI/UX direction:** modern premium enterprise SaaS look — professional,
  clean, fast, easy for factory employees. Desktop can be information-dense;
  mobile focuses on quick operational actions.

## Per-module development sequence (always, no shortcuts)

Requirement Review → Ask for Missing Process/Format → Check ISO Requirement →
Confirm Business Rules → Design Data Model → Design Workflow → Design UI →
Implement → Test → Confirm → Move to Next Module.

## Reference

- Master requirements doc: [Doc/Flexora-Master-Requirements-v1.2.md](Doc/Flexora-Master-Requirements-v1.2.md)
  - Section 3: Three QC Gates (Material Release / Production Release /
    Finished Goods Release)
  - Section 4: Master Card vs Shade Card distinction
  - Section 5: Customer & Product/SKU Master, Product Master hierarchy
  - Section 6: Material management, 5 distinct consumption values, ink
    management (unresolved, critical)
  - Section 8: Implementation Backlog — the canonical list of modules and
    what's already known/pending for each
  - Section 9: Decisions already confirmed — do not re-ask these
  - Section 10: Open Questions — do not assume answers to these; resolve
    with the user before designing the relevant module
- This CLAUDE.md file is derived from v1.2 of the master doc. If the master
  doc is updated to a new version, re-sync this file's Golden Rules / stack
  section accordingly.
