
 EMK Triage Form
# Fields:
Patient Name, Condition, Priority (1–5), Status (Pending / In‑Transit).
# Visual Coding
Priority 1  represent the highest level of priority (danger)
# Validation:
All fields are required (mandatory), priority must be an integer 1‑5.


 Offline‑First Engine
# On submit
The app checks connectivity via ConnectivityService
# If offline
record saved to Hive with isSynced = false.
# If online
attempt POST to mock API; if fails, save locally and mark for retry.
* A background SyncService listens to connectivity changes (via connectivity_plus) and processes the pending queue automatically.