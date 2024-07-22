import React from 'react';
import './WeatherList.css';

// import { AnonymousAuthenticationProvider } from "@microsoft/kiota-abstractions";
// import { FetchRequestAdapter } from "@microsoft/kiota-http-fetchlibrary";
// import { createWeatherClient } from "../../ApiClients/weatherClient.ts"

// const authProvider = new AnonymousAuthenticationProvider();
// const adapter = new FetchRequestAdapter(authProvider);
// const client = createWeatherClient(adapter);

// function getWeatherForecast() {
//   try {
//       const weather = client.weatherforecast.get();
//       return weather || [];
//   } catch (error) {
//       console.error(error);
//       return [];
//   }
// }

export const WeatherList = () => {
//   const [weather, setWeather] = React.useState([]);

//   React.useEffect(() => {
//       getWeatherForecast().then((weather) => setWeather(weather));
//   }, []);

  return (
      <div>
          <table>
              <thead>
                  <tr>
                      <th>Date</th>
                      <th>Temp. (°C)</th>
                      <th>Temp. (°F)</th>
                      <th>Summary</th>
                  </tr>
              </thead>
              {/* <tbody>
                  {weather.map((item) => (
                      <tr key={JSON.stringify(item.date)}>
                          <td>{`${item.date.day}/${item.date.month}/${item.date.year}`}</td>
                          <td>{item.temperatureC}</td>
                          <td>{item.temperatureF}</td>
                          <td>{item.summary}</td>
                      </tr>
                  ))}
              </tbody> */}
          </table>
      </div>
  );
}