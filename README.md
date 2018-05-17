# MAD Escrow

## Mutually Assured Destruction Escrow Contract in Solidity

### Designed for implementation in otc VEO <-> ETH swaps but easily used for alternative trustless transactions.

This escrow contract uses a similar mechanism as the MAD escrow protocol.
https://pbs.twimg.com/media/DcsJhB7VQAA-kHx.jpg?name=orig
www.particl.io

MAD = mutually assured destruction. The significance of this title is that
both the buyer and seller are disincentivized to cheat since neither would
be able to take actions that would harm the other party without also harming
themselves to an equal extent.

Imagine this scenario:
Buyer A wants to purchase some VEO from Seller B using ETH. Let's assume
that the 2 parties agree to make the trade for 10 VEO in exchange for 5 ETH.
Who sends first? or do they use an escrow service?
Without a trusted third party one of the parties will be taking on a large risk.

The escrow contract eliminates the need for a 3rd party and works as follows:
- BOTH Buyer A and Seller B deposit 5 ETH into the escrow contract.
- Buyer A deposits an additional 5 ETH (or all 10 at once to save in txn fees).
- Seller B sends the 10 VEO to Buyer A and Finalizes the escrow contract.
- Buyer A confirms the receipt of VEO and also Finalizes the escrow contract.
- Seller B receives their 5 ETH deposit and 5 ETH from Buyer A.
- Buyer A receives their 5 ETH deposit.
- If either party does not finalize then neither party receives any of the funds.

Now let's imagine that either the buyer or the seller has bad intentions.
Since BOTH parties must sign off to finalize the escrow otherwise BOTH lose their
funds in the escrow contract they are disincentivized from not doing the right thing.
If Buyer A receives the VEO but doesn't finalize then they will have paid 2x the original
amount agreed upon in trade.
If Seller B doesn't send the VEO they will lose the amount they would have received for
the VEO in addition to not getting paid.
