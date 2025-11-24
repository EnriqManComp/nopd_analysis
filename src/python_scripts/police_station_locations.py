import pandas as pd

# Read police station csv data
police_stations = pd.read_csv("data\Police_Stations_20251115.csv")
##

# Create two fields -> latitude and longitude
police_stations[['lon', 'lat']] = police_stations['the_geom'].str.extract(r'POINT \((-?\d+\.\d+)\s+(\d+\.\d+)\)')
police_stations.drop(columns=['the_geom'], inplace=True)
print(police_stations.head())
##

# Save the transformations
police_stations.to_csv('data\clean_data\police_stations_clean.csv')






