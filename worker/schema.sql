CREATE TABLE IF NOT EXISTS receipts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL,
  supplier TEXT NOT NULL,
  primary_unit TEXT NOT NULL,
  primary_qty REAL NOT NULL,
  secondary_unit TEXT,
  secondary_qty REAL,
  weight REAL NOT NULL,
  weight_unit TEXT NOT NULL,
  note TEXT,
  received_by TEXT,
  received_at TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  checked_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_receipts_status ON receipts(status);
CREATE INDEX IF NOT EXISTS idx_receipts_checked_at ON receipts(checked_at);
