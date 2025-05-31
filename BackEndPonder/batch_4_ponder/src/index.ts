import { ponder } from "ponder:registry";
import { transfer } from "ponder:schema";

ponder.on("ERC20:Transfer", async ({ event, context }) => {
    
  // Transfer (index_topic_1 address from, index_topic_2 address to, uint256 value)
  const { from, to, value } = event.args;
  const { number, timestamp } = event.block;
  const { hash } = event.transaction;

  const id = `${event.transaction.hash}-${event.log.logIndex}`;
  await context.db.insert(transfer).values({
    id,
    from,
    to,
    amount: value,
    timestamp,
    blocknumber: number,
    txHash: hash,
  });
});