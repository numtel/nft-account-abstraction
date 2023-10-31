import React from 'react';

import { useNetwork } from 'wagmi';

export function Home() {
  const { chain } = useNetwork();
  return (<>
    <p>Create an account as an NFT. The owner can execute calls as the account. Owner can also set and score a list of validators for allowing others to make proposals and vote on proposals for execution from the NFT account.</p>
    <p>One of these NFTs could become self-owned so that all its calls come from proposals.</p>
  </>);
}

