from shapely import wkt
from shapely.geometry import Polygon, MultiPolygon, mapping, shape
import json
import pandas as pd

def wkt_to_geojson(wkt_str):
    """ 
        Convert multipolygon shape points to GeoJSON 
        Input:
            - wkt_str (string): wkt data in string form.
        Return:
            - GeoJSON shape data in JSON format
    """

    geo = wkt.loads(wkt_str) # Load wkt data
    return json.dumps(mapping(geo)) # Map wkt data to GeoJSON and formatting as JSON

# Load districts data
districts = pd.read_csv('data/raw_data/police reports/NOPD_Districts.csv')
# Convert wkt shape data to GeoJSON data
districts['geometry'] = districts['the_geom'].apply(wkt_to_geojson)

# convert each row to a polygon
def to_polygon(g):
    if isinstance(g, MultiPolygon):
        return max(g.geoms, key=lambda x: x.area)
    return g

districts['geometry'] = districts['geometry'].apply(to_polygon)

# export only ONE polygon (Power BI requires 1 feature per file)
colors = [
    "#e41a1c", "#377eb8", "#4daf4a", "#984ea3",
    "#ff7f00", "#ffff33", "#a65628", "#f781bf"
]

features = []

for idx, row in districts.iterrows():
    multi_polygon_str = row['geometry']
    
    # Parse JSON string if necessary
    if isinstance(multi_polygon_str, str):
        multi_polygon = json.loads(multi_polygon_str)
    else:
        multi_polygon = multi_polygon_str  # already a dict
    
    # Convert to Shapely geometry
    geom = shape(multi_polygon)
    if isinstance(geom, MultiPolygon):
        polygon = geom.geoms[0]  # take the first polygon
    else:
        polygon = geom
    
    color = colors[idx % len(colors)]
    
    # Build GeoJSON Feature
    feature = {
        "type": "Feature",
        "geometry": mapping(polygon),
        "properties": {"id": idx, "color": color}  # optional, you can add more properties
    }
    features.append(feature)

# Build single FeatureCollection
geojson = {
    "type": "FeatureCollection",
    "features": features
}

# Export to a single file
output_file = "all_polygons_for_azure_maps.json"
with open(output_file, "w") as f:
    json.dump(geojson, f)

print(f"All polygons exported in one GeoJSON file: {output_file}")
