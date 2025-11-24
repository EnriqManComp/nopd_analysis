import pandas as pd

police_stations = pd.read_csv('data\clean_data\police_stations_clean.csv') # Read district data

# Find District string pattern
police_stations['Name of Facility'] = police_stations['Name of Facility'].str.extract(r'^(\d+)(?:st|nd|rd|th)\s+District$')
# Convert to integers
police_stations['Name of Facility'] = police_stations['Name of Facility'].astype('Int64')
# Drop NaN values
police_stations = police_stations.dropna(subset=['Name of Facility'])
police_stations = police_stations.drop('Unnamed: 0', axis=1)

police_stations.to_csv('data\clean_data\police_stations_clean.csv', index=False)
print(police_stations.head())