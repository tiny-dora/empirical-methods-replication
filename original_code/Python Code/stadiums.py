import pandas as pd
import os
import geopy
import geopy.distance
import datetime


'''
This script takes the files with the sentiment analysis and adds calculates whether there was a game, and if there was
a game, calculates the distance of the tweet from the stadium
Finally, it saves the data in a new folder

'''

FOLDER = r"YOURPATH\sentiment\\"
STADIUMS = r"YOURPATH\stadiums\games_stadiums.csv"
NULL_VALUE = ""
TARGET_FOLDER=r"YOURPATH\sorted_coords\\"


def get_coords(df):
    '''
    Getting the coordinates from each Tweet
    :param df: Pandas DataFrame
    :return: New Vars in the DF for the Coords within the tweet
    '''
    locs = (df["geo"]).tolist()
    coords = []
    for i in locs:
        try:
            coo = i[i.find("'bbox':") + 9:i.find("],")].split(",")
            coo = [float(i) for i in coo]
            coords.append([(coo[1],coo[0]),(coo[3],coo[2])])
        except:
            coords.append(NULL_VALUE)
    return coords


def sort_matches(df):
    '''
    Sorting the dates within the matches
    :param df: Pandas DataFrame of the matches
    :return: DataFrame with the dates as pandas datetime
    '''
    df["year"] = (df["Date"].apply(lambda x: x[6:]))
    df["month"] = (df["Date"].apply(lambda x: x[3:5]))
    df["day"] = (df["Date"].apply(lambda x: x[0:2]))
    df['date_format'] = pd.to_datetime(dict(year=df['year'], month=df['month'], day=df['day']))

    return df

def sort_date_twitter(df):
    '''
    Sorting the dates within the tweets
    :param df: Pandas DF of the tweets
    :return: DataFrame with the dates as pandas datetime
    '''
    df["year"] = (df["created_at"].apply(lambda x: x[0:4]))
    df["month"] = (df["created_at"].apply(lambda x: x[5:7]))
    df["day"] = (df["created_at"].apply(lambda x: x[8:10]))
    df['date_format'] = pd.to_datetime(dict(year=df.year, month=df.month, day=df.day))
    return df


def sort_coords(df):
    '''
    Sorting the coordinates and finding the distance from the field
    :param df: Pandas DF
    :return: coordinates
    '''
    cords = get_coords(df)
    home_cords = list(zip(df.home_stadium_lat, df.home_stadium_long))
    away_cords = list(zip(df.away_stadium_lat, df.away_stadium_long))
    distance_a_home,distance_b_home,distance_a_away,distance_b_away=[],[],[],[]
    #There are two coordinates for the polygon, adding the distance from each one
    for i in range(0, len(cords)):

        if home_cords[i] != ('', ''):
            try:

                distance_a_home.append(geopy.distance.geodesic(cords[i][0], home_cords[i]).km)
                distance_b_home.append(geopy.distance.geodesic(cords[i][1], home_cords[i]).km)
                distance_a_away.append(geopy.distance.geodesic(cords[i][0], away_cords[i]).km)
                distance_b_away.append(geopy.distance.geodesic(cords[i][1], away_cords[i]).km)
            except:
                distance_a_home.append(NULL_VALUE)
                distance_b_home.append(NULL_VALUE)
                distance_a_away.append(NULL_VALUE)
                distance_b_away.append(NULL_VALUE)
        else:
            distance_a_home.append(NULL_VALUE)
            distance_b_home.append(NULL_VALUE)
            distance_a_away.append(NULL_VALUE)
            distance_b_away.append(NULL_VALUE)

    df['distance_a_home']=distance_a_home
    df['distance_b_home']=distance_b_home
    df['distance_a_away']=distance_a_away
    df['distance_b_away']=distance_b_away
    return df


def runtime(folder,stadium_file,target_folder):
    '''
    Running the code and finding the distances
    :param folder: Folders where the files are at
    :param stadium_file: File with the games and stadiums
    :param target_folder: Folder for the new files to be saved
    :return: New files saved in the folder with the coords and distances
    '''
    #opening the files and sorting stadiums
    osf = os.listdir(folder)
    stadiums = pd.read_csv(stadium_file)
    stadiums = sort_matches(stadiums)

    #Keeping only Tottenham Games
    stadiums = stadiums[(stadiums.Home == "Tottenham") | (stadiums.Away == 'Tottenham')]

    #Adding a value for the day after a game (would be depricated in the future)

    stadiums['day_after']=0
    stadiumsdayafter = stadiums.copy()
    stadiumsdayafter["date_format"]=stadiumsdayafter["date_format"]+datetime.timedelta(days=1)
    stadiumsdayafter['day_after'] = 1
    stadiums = pd.concat([stadiums,stadiumsdayafter])


    for i in osf:
        df = pd.read_csv(FOLDER+i)
        df = sort_date_twitter(df)
        df_merged = pd.merge(df, stadiums, on="date_format", how='left').fillna("")
        df_merged=sort_coords(df_merged)
        i = i[0:len(i)-4]+".xlsx" #keeping the option of saving XLSX files for easier inspection
        j = i[0:len(i)-5]+".csv"
        df_merged.to_csv(target_folder + j, index=False)

        #df_merged.to_excel(TARGET_FOLDER + i, index=False)


def main():
    runtime(FOLDER,STADIUMS,TARGET_FOLDER)


if __name__ == '__main__':
    main()

