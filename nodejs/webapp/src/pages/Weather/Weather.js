import React from 'react';
import { Box } from '@mui/material';
import { DrawerComponent } from '../../components/Drawer/Drawer';
import { WeatherList } from '../../components/WeatherList/WeatherList';

export const Weather = () => {

  return (
    <div className="weather-page">
         <Box sx={{ display: "flex" }}>
            <DrawerComponent />
            <Box component="main" sx={{ flexGrow: 1, pl:30 }}>
                <h1>Weather Forecast</h1>
                  <WeatherList />
            </Box>
         </Box>
    </div>
  );
};

export default Weather;