import React from 'react';
import Box from '@mui/material/Box';
import { DrawerComponent } from '../../components/Drawer/Drawer';

export const Home = () => {
    return (
        <div className="home">
         <Box sx={{ display: "flex" }}>
            <DrawerComponent />
            <Box component="main" sx={{ flexGrow: 1, pl:30 }}>
            <h1>Hello, world!</h1>
            <p>Welcome to your new app!</p>
            </Box>
         </Box>
        </div>
    );
};

export default Home;
