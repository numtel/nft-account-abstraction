import React from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Outlet, Link } from "react-router-dom";

export function Layout() {
  return (<>
    <header>
      <Link to="/"><h1>NFT Account Abstraction</h1></Link>
    </header>
    <main>
      <div id="connect">
        <ConnectButton />
      </div>
      <Outlet />
    </main>
  </>);
}

