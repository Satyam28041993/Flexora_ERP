# Flexora – Master Requirements & Process Reference
### Version 1.2 | Prakruti Graphic Pvt. Ltd. (PGPL)
**Status:** Living document — update whenever a new requirement, decision, format, or exception is confirmed.
**Rule:** This document is the single source of truth for the project. Before designing any module, check this document first.

**Product Identity (locked):**
- Product Name: **Flexora**
- Product Category: ERP + HRMS for Flexographic Label Manufacturing
- Current Implementation Company: Prakruti Graphic Pvt. Ltd. (PGPL) — Tenant #1
- Architected as a scalable product for other label manufacturing companies later, not PGPL-only.
- *(v1.1 change note: renamed product from "FlexoERP" to "Flexora" only — no requirement content changed.)*
- *(v1.2 change note: added Section 0A — Technology Stack, a permanent locked technical decision. No other requirement, workflow, decision, open question, ISO rule, or backlog item modified.)*

---

## 0. PROJECT-WIDE GOLDEN RULES (apply to every module, always)

1. **Module-by-module build.** Do not design/build a module before its stage is reached. When a stage is reached: (a) remind the user what was previously identified for it, (b) ask for the actual current process, exceptions, and business rules, (c) ask for existing company format/sheet/document, (d) ask for applicable ISO format, (e) only then design database/workflow/UI.
2. **Never invent business rules, formulas, or checklists** (wastage calculation, ink logic, QC checklists, costing logic, permissions, etc.) that have not been explicitly provided. Keep them in the Open Questions / Implementation Backlog instead.
3. **ISO Documentation & Document Control is project-wide, not a module.** Any official form/document/register/checklist/report/printable output/PDF/approval record must, before finalisation, check whether an approved ISO company format exists. Ask for it. Support document-control fields (Doc Title, Doc Number, Department, Revision No., Revision Date, Effective Date, Prepared By, Checked By, Approved By, Page No.) as per the actual supplied format — do not assume layout. Maintain revision history; never destroy traceability of which revision a historical record was created under.
4. **CRM boundary.** Lead/Enquiry/Quotation/Negotiation/initial PO currently run on the existing **Liptrack CRM** (connected to TradeIndia API) + email. Flexora does **not** replace this now. **Flexora scope starts from confirmed Order/PO + advance payment received.** Future integration between Liptrack CRM and Flexora (to avoid duplicate entry) remains a possibility, not committed yet.
5. **Revision/Change control everywhere.** Critical production references (artwork, product specs, shade card, ISO formats) must never be silently overwritten — maintain version history.
6. **Traceability is a core design value**, not a report added later — every transaction should carry job/customer/user/date/reference links from day one.
7. **Transaction-based inventory.** Stock quantities are never manually edited; every movement (receipt, issue, return, consumption, wastage, adjustment) is a logged transaction with reason + reference.
8. If two instructions from the user appear contradictory, do not silently decide — flag the conflict and ask.

---

## 0A. TECHNOLOGY STACK — PERMANENT LOCKED DECISION (v1.2)

**Status: LOCKED.** Do not change without explicit user request.

| Layer | Choice |
|---|---|
| Application framework | **Flutter** — Android, Web, desktop-friendly web, tablet-responsive; one codebase across platforms |
| Primary backend | **Firebase** |
| Database | **Cloud Firestore** (primary operational database) |
| Authentication | **Firebase Authentication** |
| File storage | **Firebase Storage** (artwork, PO, approvals, ISO documents, QC attachments, Shade Card evidence, employee documents, reports — Firestore stores metadata/references only, not large files) |
| Server-side logic | **Cloud Functions**, where genuinely required (secure business logic, automation) |
| Notifications | **Firebase Cloud Messaging** |

**Responsive design targets:**
- Desktop/Web → ERP-heavy operations: tables, production planning, inventory, reports, administration, management
- Mobile → operational tasks: approvals, production updates, QC, material transactions, attendance, quick management access
- Tablet → shop-floor usage where appropriate

**Architecture requirements:**
- Layered separation: **UI/Presentation → Business Logic → Services/Repositories → Firebase/Data Layer.** No business logic scattered in UI widgets; no screens wired directly to random Firestore collections.
- Modules (Orders, Products, Jobs, Pre-Press, Production, QC, Inventory, Purchase, Dispatch, HRMS, Payroll, Document Control, Reports) must be able to evolve independently while staying integrated.
- Firestore collections are designed only after: workflow understood → requirements confirmed → entities defined → relationships defined → permissions defined → audit requirements defined. Not an "uncontrolled NoSQL structure just because Firestore allows it."
- Database must support: traceability, revision history, audit trail, role-based access, multi-plant readiness, job-wise transactions, historical records, reporting.

**Security:**
- Firebase Authentication + Role-Based Access Control + Firestore Security Rules + Cloud Functions for sensitive operations.
- Authorization enforced at the data layer, not just by hiding UI buttons/screens — unauthorized reads/writes must be blocked even if the app UI is bypassed.

**User roles (illustrative, permissions TBD when User & Permission module is reached):**
Management, Admin, Pre-Press, Production, QC, Stores, Purchase, Sales/Order Management, Accounts, HR, Employees. Permission architecture must be scalable/configurable, not hardcoded throughout the app.

**Audit trail:** Created By/At, Updated By/At, Approved By/At, Status, Revision, Change History — exact requirements defined module by module; historical production data is never destroyed when current master data changes.

**Offline/shop-floor:** Connectivity may be imperfect on the shop floor — keep this in mind for Production/QC/Stores/Attendance design, but do **not** build complex offline architecture prematurely; evaluate per-module when reached.

**Notifications (illustrative, rules TBD module by module):** Artwork Approval Pending, Material Pending, Plate/Punch Pending, Job Ready for Planning, QC Approval Required, Production Hold, Material Shortage, Job Delayed, Dispatch Ready, Approval Required, HR Notifications.

**Reports & ISO documents:** Architecture must support generating them, but formats are never finalised without the applicable company/ISO template (per Golden Rule 3). Generated records pull from the same ERP source of truth wherever possible.

**Code quality bar:** modular architecture, reusable components, consistent naming, proper error handling, loading/empty states, input validation, responsive UI, minimal duplication, secure Firebase access, scalable Firestore queries, logging where required. No shortcuts that create problems as Flexora grows.

**UI/UX direction:** Modern premium enterprise SaaS look — professional, clean, premium, futuristic but practical, fast, easy for factory employees, responsive, consistent across modules. Desktop can be information-dense where needed; mobile focuses on quick operational actions.

**Firebase cost/scale discipline:** Design Firestore queries/data structures efficiently — avoid unnecessary reads, redundant real-time listeners, downloading large collections wholesale, excessive writes, poorly structured queries. Every module designed with scale and cost efficiency in mind from the start.

**Future integration readiness (not in current scope, but don't architect against them):** Liptrack CRM, Tally/accounting, Email, WhatsApp, Barcode/QR, Biometric systems, Customer/Supplier APIs, other manufacturing systems. Implement only when explicitly required.

**Per-module development approach (reconfirmed):**
Requirement Review → Ask for Missing Process/Format → Check ISO Requirement → Confirm Business Rules → Design Data Model → Design Workflow → Design UI → Implement → Test → Confirm → Move to Next Module. Always check this Master Requirements document first.

---

## 1. Company Context

| Item | Detail |
|---|---|
| Company | Prakruti Graphic Pvt. Ltd. (PGPL Group) |
| Location | Vasai East, Dist. Palghar, Maharashtra |
| Industry | Flexographic label printing, security printing & packaging |
| Core equipment | Lombardy 8-colour Flexo Press, ~430mm max web width |
| Product lines | Self-adhesive labels, printed labels, security/tamper-evident labels, holograms/micro-embossing, shrink sleeves, leaflet labels, lamination labels |
| Customer segments | Pharma, FMCG, Food & Beverage, Cosmetics, Agrochemical, Liquor/Security |
| Existing systems | Liptrack CRM (TradeIndia-connected), Tally, Google Sheets, Excel |
| Plant scope | Single plant now; architecture must allow multi-plant later (`plant_id` on all tables from day 1) |

---

## 2. CURRENT BUSINESS WORKFLOW (as explained by the user — this is the ACTUAL process, not an idealised one)

### 2.1 Pre-Flexora scope (handled by Liptrack CRM + email — not built in Flexora now)
- Enquiry sources: References, Liptrack CRM (TradeIndia API leads), repeat customer direct enquiry, walk-in, direct call
- Rate fixing → Quotation → sent via WhatsApp/Email → Customer confirms via email

### 2.2 Flexora scope begins here: Order Confirmation → Dispatch

```
PO + Advance Payment Received
      ↓
Artwork Requested from Customer
      ↓
Pre-Press: Artwork Check & Preparation
      ↓
Artwork sent to Customer for Approval
      ↓
Customer Approves Artwork  →  Job Approved
      ↓
Job Entry (currently: common Google Sheet — shared with Production & Material/Purchase teams)
      ↓
Material Planning (check stock → purchase if short)
      ↓
Plate ordered (~2–3 days lead time) & Punch/Die ordered (~1 day lead time)
      ↓
Plate & Punch Received → Pre-Press Verification (against approved job requirements)
      ↓
Pre-Press prepares: Job Card + Master Card
      ↓
Physical Handover to Production (Master Card + Job Card + Plate + Punch/Die)
      ↓
Production Planning / Scheduling (date decided)
      ↓
Job Scheduled for Printing
      ↓
[On scheduled date] Machine/Job Setting → Initial Print Sample
      ↓
Start-Up QC (QC Gate 2 — production RELEASE gate; full production starts ONLY after this approval)
      ↓
Shade Card created during printing (Standard / Dark / Light) → Customer Approval → stored as permanent reference
      ↓
Full Production Run (printing)
      ↓
[FLEXIBLE ROUTE — varies per job, defined at Job Card/Product Master level, not hardcoded]
   Online Punching (during printing)  OR  Offline Punching (separate stage)
   optional: Hot Foil Stamping / Blind Embossing / UV Embossing / other special processes
      ↓
Checking (only after ALL applicable processes for that job are done)
      ↓
Slitting
      ↓
Final QC (QC Gate 3 — Finished Goods RELEASE gate; validates against customer's final delivery requirements)
      ↓
Packing
      ↓
Dispatch
```

**Critical design principle confirmed by user:** The production route (which processes apply, and in what order) is **not fixed** — it must be configurable per Job Card / Product Master. Example variations:
- Job A: Printing → Online Punching → Checking → Slitting → Packing → Dispatch
- Job B: Printing → Offline Punching → Checking → Slitting → Packing → Dispatch
- Job C: Printing → Hot Foil Stamping → Offline Punching → Checking → Slitting → Packing → Dispatch
- Job D: Printing → Blind Embossing → Checking → Slitting → Packing → Dispatch

---

## 3. THREE QC GATES (confirmed structure — treated as three separate, non-overlapping control records)

| Gate | Stage | Trigger | Releases |
|---|---|---|---|
| **QC Gate 1 — Material Release** | Incoming Material QC | Material received from vendor | Material available for production |
| **QC Gate 2 — Production Release** | Start-Up QC | Machine/job setting done, initial print sample achieved | Full production run allowed to start |
| **QC Gate 3 — Finished Goods Release** | Final QC | After all applicable processes + Checking + Slitting | Packing/Dispatch allowed |

- **In-Process QC** (during printing, linked to the production run and to approved artwork/shade references) is conceptually distinct from **Post-Production Checking** (after all processes complete) — do not merge these.
- Start-Up QC checks (indicative, checklist TBD): text matter correctness, artwork/content correctness, colour/shade match against approved Shade Card, print quality, spec correctness, Rub Test, other job-specific checks.
- Final QC checks (indicative, checklist TBD): winding/unwinding direction, label orientation, labels/roll count, roll specs, slitting requirements, finished product condition, packing requirements/method, packing list, quantity vs customer requirement.
- Exact checklists for all three gates: **pending — user will provide.**

---

## 4. MASTER CARD vs SHADE CARD (critical distinction — do not confuse)

| | Master Card | Shade Card |
|---|---|---|
| When created | Before printing (part of Pre-Press verification package) | During printing, from actual production output |
| Purpose | Physical production reference package (with Job Card, Plate, Punch/Die) | Establish approved colour/shade reference |
| Contains | TBD — user will provide existing format | Standard / Dark / Light shade samples |

### Shade Card — critical control requirement
- Must be **approved by the customer**; approved Shade Card becomes a **permanent reference** for that customer/product.
- **First job:** Print → Shade Card created (Std/Dark/Light) → Customer Approval → Stored as permanent reference.
- **Repeat job:** Retrieve previous approved Shade Card → use as printing/colour-matching reference → Production.
- **Current operational problem:** Shade Card creation is sometimes missed during production — this is a known control gap Flexora must help close.
- ERP must show clear status per job: Pending / Created / Customer Approval Pending / Approved / Approved Reference Available.
- Must maintain **history**, not overwrite.
- Digital record should link: Customer → Product → Job → Artwork Version → Shade Card → Approval, with fields such as Shade Card ID, Customer, Product/Job, Job Card No., Artwork Version, Date Created, Production Batch/Run, Std/Dark/Light shade reference, Approval Status, Customer Approval Date, Approval Evidence, Created By, Approved/Recorded By, physical storage/reference location, Remarks (exact fields to be finalised).
- Repeat-job logic: system should auto-detect if an approved Shade Card already exists for that customer/product spec and flag **"APPROVED SHADE REFERENCE AVAILABLE."**
- Rules for what happens if artwork/material/ink/spec/customer requirement changes after a shade was approved — **not yet defined, pending.**

---

## 5. CUSTOMER & PRODUCT/SKU MASTER (critical — single source of truth for repeat production)

### Hierarchy
```
CUSTOMER → PRODUCT/SKU → PRODUCT MASTER → Artwork + Production Specs + Tooling + Shade + QC + Job History
```

### 5.1 Customer Master (fields identified)
Customer ID/Code, Company Name, Billing details, GST/Tax info, Contact persons, Email/Phone, Billing Address, Shipping Address(es), customer-specific instructions, general packing requirements, general QC requirements, Active/Inactive status.

### 5.2 Product/SKU Master
- Every unique label/product gets a **permanent internal Product ID/SKU Code** (do not rely on customer product names alone — they can be similar/confusing).
- Must be searchable by: Customer, Product Name, SKU/Product Code, Customer Product Code, Artwork Name, Job Card Number, PO Number, Label Size, Barcode (where applicable).

### 5.3 Product Master — technical specification (stores the *approved* manufacturing spec)
- **General:** Customer, Product Name, Internal SKU Code, Customer Product Code, Description, Active/Inactive status
- **Label Specification:** Width, Height, Shape, Material/Substrate, GSM/Micron, Adhesive, Liner/Release Liner, Face Material, special material requirements
- **Printing Specification:** No. of colours, colour details, Pantone/colour references, printing method, Varnish, Lamination, special coating
- **Machine/Conversion Specification:** Web Size, Cylinder/Repeat, Across UPS, Around UPS, Punch/Die, Core Size, Labels per Roll, Winding Direction, Label Orientation, Slitting specification
- **Special Processes:** which processes apply to this product (Online/Offline Punching, Hot Foil, Blind Embossing, UV Embossing, Lamination, others) — **configurable route**, this is where the flexible process-route (Section 2) gets defined at the product level

### 5.4 Artwork Management (per Product Master)
Current Approved Artwork, Artwork Version, Approval Date, Approval Evidence, Artwork File, Previous Artwork Versions (history), Created/Uploaded By, Status. Never overwrite historical approved artwork; always track which version was used on which Job Card/production run.

### 5.5 Repeat Job Management
Repeat jobs should reuse the latest applicable approved Product Master info: artwork, plate/die, shade reference, manufacturing spec. Historical Job Cards must remain unchanged (immutable once created/executed).

---

## 6. MATERIAL MANAGEMENT (critical — job-wise accountability is the core requirement)

### 6.1 Full traceability chain
```
Material Requirement → Purchase/Existing Stock → Material Receipt → Incoming QC → Stock
→ Job-wise Material Issue → Actual Consumption → Material Return → Wastage → Closing Stock
```

### 6.2 Material Planning
- Job Approved → Material Requirement generated → **check available stock first**
  - If available: reserve/use existing stock
  - If short/unavailable: Purchase Requirement → Order → Receipt → Incoming QC → Available for production
- Today this requirement/spec info lives in the shared Google Sheet (customer/job details, approved artwork details, material type/spec, required web size, material requirement quantity, vendor).

### 6.3 Material Request from Production
Formal **Material Requisition**, linked to Job Card, identifying: Job Card, Customer, Material Type, Material Specification, Required Roll/Web Width, Required RMT, other params.

### 6.4 Material Issue from Stock
Stores identifies and physically issues the correct roll. Every issue must be linked to a specific Job Card (Stock Roll → Material Issue → Job Card → Production) — material should never "disappear" from general inventory untracked.

### 6.5 Material Consumption — FIVE DISTINCT VALUES (never treat as the same number)
1. **Planned Material** — theoretical requirement per Job Card/planning
2. **Issued Material** — what Stores physically issued
3. **Actual Consumption** — what was actually used in production
4. **Returned Material** — usable leftover returned to Stores
5. **Wastage** — consumed/lost beyond usable finished production (**formula not yet defined — pending user input**)

### 6.6 Leftover Roll Return
Issued Roll → Production Usage → Job Completed → Remaining Roll → Returned to Stores → Inventory updated (remaining RMT becomes available stock again, reusable for future suitable jobs).

### 6.7 Job-wise Material Reconciliation
Per Job Card: Planned vs Issued vs Actual Consumption vs Returned vs Wastage.
Confirmed (non-wastage) formula: `Issued − Returned = Net Material Taken from Stock for the Job`.
Actual consumption/wastage calculation logic: **pending, will be provided separately — do not assume.**

### 6.8 Roll-Level Inventory
Individual rolls must be traceable (not just aggregate stock totals): Material, Width, Original RMT, Available RMT, Vendor, Receipt info, Batch/Lot (where applicable), QC status, current stock status. Partial-return RMT becomes available stock again. Roll ID/barcode/QR method — decision deferred (barcode/QR itself is a future-phase item per earlier decision).

### 6.9 Ink Management — CRITICAL, UNRESOLVED
- Ink comes in containers/cans; one container is used across multiple production runs, making accurate job-wise consumption currently very hard to determine.
- Currently no visibility into: ink issued, ink consumed per job, ink remaining, actual job-wise ink cost, ink wastage, closing ink stock.
- **Status: CRITICAL REQUIREMENT – LOGIC TO BE DEFINED.** Do not design tracking logic until the user explains how ink is physically handled in production.

### 6.10 Other Production Materials
Foil, Lamination material, Varnish, other consumables — each may need a different tracking unit/method (e.g., roll material = width+RMT based; ink = weight-based). Do not assume one method fits all materials. Eventually integrate with: Inventory → Job Card → Material Issue → Production Consumption → Return (where applicable) → Wastage → Job Costing.

### 6.11 Design principle
Material inventory must be **transaction-based** (see Golden Rule 7) — every movement type (Purchase Receipt, Material Issue, Material Return, Consumption, Wastage, Stock Adjustment) is its own logged transaction linked to Job Card, user, date/time, and material/roll.

---

## 7. TRACEABILITY CHAIN (target end-state, across all modules)

```
Customer → Product → Artwork Version → Job Card → Master Card → Plate → Punch/Die
→ Production Run → Shade Card → Customer Shade Approval → In-Process QC
→ Material Issued/Consumed/Returned/Wastage → Finished Job → Final QC → Dispatch
```
Used for: inventory accuracy, material/purchase planning, wastage analysis, job costing, job profitability, production efficiency, vendor/material traceability, repeat-job reference lookup, and customer complaint/rejection investigation.

---

## 8. IMPLEMENTATION BACKLOG
*(Requirements identified but deliberately NOT yet designed in detail — do not build ahead of the actual workflow stage. When we reach each item: remind the user it was identified here, ask for existing format/process/business rules/ISO template, then design.)*

1. **Customer & Product/SKU Master** — see Section 5
2. **Artwork Version Control** — never overwrite approved artwork; track version used per Job Card/run
3. **Master Card** — digitise existing format; ask for current Master Card template
4. **Job Card** — build from actual existing Job Card format; ask for current format
5. **Plate Management** — track against Customer/Product/Artwork Version: availability, condition, storage location, replacement, repeat-job usage
6. **Punch/Die Management** — master + linkage to products/jobs: spec, storage location, condition, usage
7. **Shade Card Management** — see Section 4 (already well-defined structurally; digital record fields still TBD)
8. **Production Planning & Scheduling** — ask how production is actually planned/prioritised today before designing
9. **Production Data Capture** — machine, operator, quantity/RMT, setup, start/end time, downtime, rejection — exact format TBD
10. **Material Management** — see Section 6 (structurally defined; wastage & ink formulas pending)
11. **Wastage Management** — **VERY CRITICAL, formula not defined** — must get actual business rules before implementing any calculation
12. **Ink Management** — **VERY CRITICAL, unresolved** — see Section 6.9
13. **Foil, Lamination & Other Consumables** — job-wise stock/issue/consumption/return/wastage integration
14. **QC Management** — see Section 3; exact checklists per gate still TBD
15. **QC Failure / Hold / Rework / Rejection** — workflow and business rules TBD
16. **Finished Roll Traceability** — quantity, labels/roll, roll ID, winding direction, core, job/batch reference
17. **Packing & Dispatch** — packing list, boxes/rolls, dispatch, partial dispatch, balance tracking — existing formats TBD
18. **Repeat Job Management** — see Section 5.5
19. **Revision & Change Control** — project-wide (Golden Rule 5)
20. **Job Costing & Profitability** — material, ink, foil/lamination, plate, die, wastage, machine cost, special processes, other costs — exact logic TBD
21. **Customer Complaint / Reprint / Rejection** — link original job ↔ complaint ↔ internal rejection ↔ reprint ↔ corrective action
22. **Purchase & Vendor Management** — integrate material requirement → purchase → vendor → receipt → Incoming QC
23. **HRMS** — employee master, departments, shifts, attendance (web+Android, GPS/selfie punch — per earlier decision), leave, overtime, payroll, permissions (detailed design deferred)
24. **User Roles, Approvals & Permissions** — Management, Pre-Press, Production, QC, Stores, Purchase, Sales, Accounts, HR — detailed permissions during implementation
25. **Audit Trail** — who created/changed/approved/processed what and when, for critical transactions
26. **Management Dashboard & Reporting** — after core transactional modules are stable: production, material, wastage, QC, pending jobs, delivery, costing KPIs
27. **ISO Documentation & Document Control** — project-wide rule (Golden Rule 3), formats to be supplied progressively

---

## 9. DECISIONS ALREADY CONFIRMED (do not re-ask these)

| Area | Decision |
|---|---|
| Plant scope | Single plant now; multi-plant-ready architecture (`plant_id` from day 1) |
| Data migration source | Google Sheets, Tally, Excel |
| Artwork approval today | Mostly via email |
| Barcode/QR on rolls/cartons | Future phase (not at launch) |
| GST e-invoicing/e-way bill | Manual entry for now, no direct govt API integration yet |
| Attendance | Move fully onto Flexora web + Android app (GPS + selfie punch), with a transition-period bridge to import existing biometric logs |
| Payroll | Fully in-house (accountant runs everything) — HRMS should support full payroll processing, not just export |
| CRM scope | Liptrack CRM (+ email) continues to own Lead→Quotation→PO; Flexora starts at confirmed PO/advance payment |
| Rollout priority | Sales+Job Card+Production → Inventory+QC → Dispatch+Invoice → HRMS → Dashboards *(Note: with the CRM boundary now clarified, "Sales" in Phase 1 effectively means Order/PO intake onward, not lead management — flagged in Section 10 for confirmation)* |

---

## 10. OPEN QUESTIONS & PENDING BUSINESS RULES
*(Do not assume answers to these. To be resolved before the relevant module is designed.)*

**Immediate / structural clarifications:**
1. Given the CRM boundary decision (Section 2.1), should the earlier Phase 1 definition ("Sales + Job Card + Production") be re-labelled to start at **Order/PO Intake** rather than Enquiry/Sales? (Flagging a possible contradiction with the earlier rollout-priority wording — needs your confirmation, not assumed.)
2. What does "Job Entry" into the Google Sheet actually contain field-by-field today? (You've described its contents at a high level — an actual sample sheet would help lock the Job Card's data fields.)

**Formats needed before finalising the respective module (per Golden Rule 1 & 3):**
3. Existing Job Card format
4. Existing Master Card format
5. Existing Shade Card physical format/register
6. Incoming Material QC checklist/format
7. Start-Up (Printing Setup) QC checklist/format
8. Final QC checklist/format
9. Material Requisition / Issue / Return format (Stores)
10. Production Data Capture format (machine/shift/operator log)
11. Packing List / Dispatch Challan format
12. Any ISO-controlled formats for the above (document numbers, revision control fields, approval signatories)

**Business rules not yet defined:**
13. Wastage calculation logic (setup waste vs running waste vs rejection — how are these currently computed/recorded, if at all?)
14. Ink consumption tracking methodology (how ink containers are physically handled/shared across jobs)
15. QC failure/hold/rework/rejection workflow rules
16. Production scheduling/prioritisation rules (how is "which job runs when" actually decided today?)
17. Detailed job costing formula (which cost components, how overhead/machine-hour rates are set)
18. Exact user roles/permissions matrix (module × action × role)

---

## 11. Storage & Update Process
This document is maintained as a file in this Claude Project's outputs (`Flexora-Master-Requirements-v1.0.md`) and should be re-shared/updated (new version number) whenever:
- A new requirement is added
- A business rule is confirmed
- A workflow changes
- An ISO format is provided
- A calculation is finalised
- An exception is identified
- A module is completed
- An important architecture decision is made

**Note on persistence:** This is a chat artifact file, not automatically "remembered" by Claude between sessions unless referenced. For reliability, keep this file (and future dated versions) in your Project's knowledge/files area, and reference "the Master Requirements Document" explicitly when starting new module discussions so it can be re-read before design begins.
