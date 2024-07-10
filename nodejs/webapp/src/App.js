import React from 'react';
import { Routes, Route, BrowserRouter } from "react-router-dom";
import { Home } from './pages/Home/Home';
import { Weather } from './pages/Weather/Weather.js';
import './App.css';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" exact element={<Home />} />
        <Route path="/weather" exact element={<Weather />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
