import geopandas as gpd
import numpy as np
import pandas as pd
from shapely.geometry import Polygon, LineString, Point
import os

GEO_PATH = r"YOURPATH\uk_geography\\"
TWITTER_PATH = r"YOURPATH\sorted_coords\\"
DISTRICTS = r"YOURPATH\districts\\"
NULL_VALUE = ""

def get_coords(df):
    '''
    Seperating the coordinates within each tweet. Each tweet has two coordinates

    :param df: Pandas DataFrame
    :return: coordinates of each tweet
    '''
    locs = (df["geo"]).tolist()
    coords = []
    for i in locs:
        try:
            coo = i[i.find("'bbox':") + 9:i.find("],")].split(",")
            coo = [float(i) for i in coo]
            coords.append([(coo[0],coo[1]),(coo[2],coo[3])])
        except:
            coords.append(NULL_VALUE)
    return coords

def open_geo(path):
    '''
    Opening the districts file of the United Kingdom
    :param path: Path to the file
    :return: file as geo df
    '''
    file_name = 'district_borough_unitary_region.shp'
    df = gpd.read_file(path + file_name)
    df.to_crs(epsg=4326, inplace=True)
    return df

def add_coords_first(df):
    '''
    Matching the first set of coordinates from each tweet to the districts
    :param df:Pandas DF
    :return: District of the tweet by first set of coords
    '''
    coords=get_coords(df)

    coords_first_border = [i[0] if len(i) == 2 else NULL_VALUE for i in coords]
    df["long_first"] = [i[0] if len(i) == 2 else NULL_VALUE for i in coords_first_border]
    df["lat_first"] = [i[1] if len(i) == 2 else NULL_VALUE for i in coords_first_border]

    df = df[df.long_first != ""]
    df = df[df.lat_first != ""]
    geodf = gpd.GeoDataFrame(
        df, geometry=gpd.points_from_xy(df.long_first, df.lat_first), crs=4326)

    return geodf

def add_coords_second(df):
    '''
    Matching the second set of coordinates from each tweet to the districts
    :param df:Pandas DF
    :return: District of the tweet by second set of coords
    '''
    coords=get_coords(df)

    coords_second_border = [i[1] if len(i) == 2 else NULL_VALUE for i in coords]
    df["long_second"] = [i[0] if len(i) == 2 else NULL_VALUE for i in coords_second_border]
    df["lat_second"] = [i[1] if len(i) == 2 else NULL_VALUE for i in coords_second_border]

    df = df[df.long_second != ""]
    df = df[df.lat_second != ""]
    geodf = gpd.GeoDataFrame(
        df, geometry=gpd.points_from_xy(df.long_second, df.lat_second), crs=4326)

    return geodf

def sort_coords_final(geo_file,file_path):
    '''
    Sorting the coords and adding district. If there are two different districts by coords, the second one is chosen
    :param geo_file: Pandas geo file
    :param file_path: Path to file
    :return:
    '''
    geodf = geo_file
    tweets = pd.read_csv(file_path)
    geodf_first = add_coords_first(tweets)
    geodf_second= add_coords_second(tweets)
    merged_file_first = gpd.sjoin(geodf_first, geodf, how='left', op='within')
    merged_file_second = gpd.sjoin(geodf_second, geodf, how='left', op='within')
    merged_file_second["first_district_name"]=merged_file_first["NAME"]
    merged_file_second["district_name"]=np.where(merged_file_second.NAME.isna()==True,merged_file_second["first_district_name"],merged_file_second["NAME"])
    return merged_file_second

def add_district(geo_path,files_path,target_folder):
    '''
    Adding the districts to each file and saving in a new file
    :param geo_path: Path to districts file
    :param files_path: Path to files
    :param target_folder: Folder where the files are to be saved
    :return: Files with district in a new folder
    '''
    file_names = os.listdir(files_path)
    geo_file = open_geo(geo_path)
    file_names_csv = []
    for i in file_names:
        if i.endswith("csv"):
            file_names_csv.append(i)
    for file_name in file_names_csv:
        df_district = sort_coords_final(geo_file,files_path+file_name)
        df_district.to_csv(target_folder+file_name,index=False)



def main():
    add_district(GEO_PATH,TWITTER_PATH,DISTRICTS)


if __name__ == '__main__':
    main()

