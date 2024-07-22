import * as React from 'react';
import { styled } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import CssBaseline from '@mui/material/CssBaseline';
import List from '@mui/material/List';
import Divider from '@mui/material/Divider';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import HomeIcon from '@mui/icons-material/Home';
import WbSunnyIcon from '@mui/icons-material/WbSunny';
import { useNavigate } from 'react-router-dom';

const DrawerHeader = styled('div')(({ theme }) => ({
  display: 'flex',
  alignItems: 'center',
  padding: theme.spacing(0, 1),
  justifyContent: 'flex-end',
}));

export const DrawerComponent = () => {
  const [open] = React.useState(true);
  const navigate = useNavigate();

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <Drawer variant='permanent' open={open}>
        <DrawerHeader>
        </DrawerHeader>
        <Divider />
        <List>
            <ListItem disablePadding sx={{ display: "block", flexGrow: 1, p: 1}} onClick={()=>{navigate("/")}}>
                <ListItemButton
                sx={{
                    minHeight: 48,
                    justifyContent: open ? "initial" : "center",
                    px: 2.5,
                }}
                >
                    <ListItemIcon
                    sx={{
                        minWidth: 0,
                        mr: open ? 3 : "auto",
                        justifyContent: "center",
                    }}
                    >
                        <HomeIcon />
                    </ListItemIcon>
                    <ListItemText primary="Home" sx={{ opacity: open ? 1 : 0}} />
                </ListItemButton>
            </ListItem>
            <ListItem disablePadding sx={{ display: "block", flexGrow: 1, p: 1 }} onClick={()=>{navigate("/weather")}}>
                <ListItemButton
                sx={{
                    minHeight: 48,
                    justifyContent: open ? "initial" : "center",
                    px: 2.5,
                }}
                >
                    <ListItemIcon
                    sx={{
                        minWidth: 0,
                        mr: open ? 3 : "auto",
                        justifyContent: "center",
                    }}
                    >
                        <WbSunnyIcon />
                    </ListItemIcon>
                    <ListItemText primary="Weather" sx={{ opacity: open ? 1 : 0}} />
                </ListItemButton>
            </ListItem>
        </List>
      </Drawer>
      <Box>
      </Box>
    </Box>
  );
}