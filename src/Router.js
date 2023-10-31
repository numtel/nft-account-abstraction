import React from 'react';
import { BrowserRouter, Routes, Route, Navigate, useParams } from "react-router-dom";
import { Layout } from './components/Layout.js';
import { Home } from './pages/Home.js';
import { defaultChain } from './contracts.js';

export function Router() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index
            element={<Home />}
          />
          <Route
            path="lotto/:chainId/:collection/:tokenId"
            element={<Home />}
          />
          <Route path="*" element={<>nomatch</>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
