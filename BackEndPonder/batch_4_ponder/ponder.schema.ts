import { onchainTable } from "ponder";

// Data requirement:
// Tx Hash
// From (address)
// To (address)
// Amount
// Timestamp
// Block number

export const transfer = onchainTable("transfer", (t) => ({
  id: t.text().primaryKey(),
  txHash: t.text().notNull(),
  from: t.text().notNull(),
  to: t.text().notNull(),
  amount: t.bigint().notNull(),
  timestamp: t.bigint().notNull(),
  blocknumber: t.bigint().notNull(),
}));