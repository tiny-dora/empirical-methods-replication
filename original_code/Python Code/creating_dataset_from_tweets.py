import pandas as pd
import os
import requests
import numpy as np

'''
Creating a dataset from all of the tweets in a folder. All tweets must have districts, distance from stadiums 
and sentiment. We are converting the tweets to a dataset where each observation is a district on a single day with the 
positive, negative, neutral and total number of tweets summed values are variables

'''


PATH = r"YOURPATH\districts\\"
TARGET = r"YOURPATH\csv_files\\"


def add_closeness(df,thresh=30):
    '''
    Adding whether a tweet was close to the event by a threshold. The default is 30
    :param df: DF of files
    :param thresh: Thresh of distance to be deemed "close"
    :return:
    '''
    df["distance_home"] = (df["distance_a_home"]+df["distance_b_home"])/2
    df["distance_away"] = (df["distance_a_away"]+df["distance_b_away"])/2
    df["close_home"] = np.where(df["distance_home"]<thresh,1,0)
    df["close_away"] = np.where(df["distance_away"]<thresh,1,0)




def create_groupby_date(col_key, df):
    #Depricated
    '''
    Creating a groupby of the dates and adding a column for each search by positive negative and neutral
    :param col_key: Columns to be grouped by
    :param df: DF of the games
    :return:
    '''
    df['date_format'] = pd.to_datetime(dict(year=df.year, month=df.month, day=df.day))
    df = df.groupby(['date_format'])[['positive', 'neutral', 'negative']].sum().reset_index()
    df = df.rename(columns={"positive": col_key + "_pos", "neutral": col_key + "_nue", "negative": col_key + "_neg"})
    return df


def create_groupby_date_location(path,close_thresh):
    '''
    Creating a unique value for each location with the positive, negative and no sentiment per each area
    :param path: Path to folder
    :return: One file for all searches grouped by days
    '''
    directory_files = os.listdir(path)
    directory_files = [i for i in directory_files if i.endswith("csv")]
    print(directory_files)
    #Creating shortened versions of the file names to be saved as columns
    col_shorts = [i[0:3] for i in directory_files]
    total_file = pd.DataFrame()
    #Columns to be saved for the final file
    all_names = ['close_home','close_away']
    # taking each file and adding a column for each file taking 1 if the results are from the file and zero o.w (3 first letters)
    for i in range(0, len(directory_files)):
        df = pd.read_csv(path + directory_files[i]) #Opening the file
        print(df.columns) #checking that the columns are fine to be depricated in the final version
        #Adding the closeness
        add_closeness(df,close_thresh)


        for j in col_shorts:
            df[j] = 0
        df[directory_files[i][0:3]] = 1
        total_file = pd.concat([df, total_file])
    #Adding the positive, negative and neutral scores as correct variables and appending them to the columns being saved
    for name in col_shorts:
        total_file[name + "_pos"] = total_file[name] * total_file["positive"]
        total_file[name + "_neg"] = total_file[name] * total_file["negative"]
        total_file[name + "_neu"] = total_file[name] * total_file["neutral"]
        all_names.extend([name + "_pos", name + "_neg", name + "_neu", name])
    # Adding the variables of the soccer matches
    soccer_file=total_file[["date_format","HomeGoals","AwayGoals","Home","Away","FTR","day_after"]].fillna("").drop_duplicates()
    print(soccer_file)
    #Using group by and keeping the right variables
    gbitem = total_file.groupby(["district_name", 'date_format'])[all_names].sum().reset_index()
    gbitem = pd.merge(gbitem,soccer_file,how='left',on='date_format')
    return gbitem


def add_military_operations(df):
    '''
    Adding military operations for Zuk Eitan, Operation closed garden, Operation blackbelt, Operation Gurdians of the walls, and the American embassy moving to Jerusalem
    :param df:DF of the final file
    :return:New variables for each event and the events in total
    '''
    zuk = (df['date_format'] > '2014-06-11') & (df['date_format'] <= '2014-08-27').astype(int)
    garden = (df['date_format'] > '2019-05-02') & (df['date_format'] <= '2019-05-07').astype(int)
    blackbelt = (df['date_format'] > '2019-11-11') & (df['date_format'] <= '2019-11-15').astype(int)
    walls = (df['date_format'] > '2021-05-09') & (df['date_format'] <= '2021-05-22').astype(int)
    embassy_dec = (df['date_format'] > '2017-12-05') & (df['date_format'] <= '2017-12-09').astype(int)
    embassy_mov = (df['date_format'] > '2018-05-13') & (df['date_format'] <= '2018-05-15').astype(int)

    df['zuk'] = zuk.astype(int)
    df['garden'] = garden.astype(int)
    df['blackbelt'] = blackbelt.astype(int)
    df['walls'] = walls.astype(int)
    df['embassy_dec'] = embassy_dec.astype(int)
    df['embassy_mov'] = embassy_mov.astype(int)
    df["events"] = df['zuk'] + df['garden'] + df['blackbelt'] + df['walls'] + df['embassy_dec'] + df['embassy_mov']


def add_time(df):
    '''
    Adding dates as datetime
    :param df: Df
    :return: Df with dates as datetime
    '''
    # df["year"]=df["date_format"].apply(lambda x: x[0:4])
    # df["month"]=df["date_format"].apply(lambda x: x[5:7])
    # df["day"]=df["date_format"].apply(lambda x: x[8:10])
    df["weekday"] = pd.to_datetime(df.date_format).dt.dayofweek
    df["day"] = pd.to_datetime(df.date_format).dt.day
    df["month"] = pd.to_datetime(df.date_format).dt.month
    df["year"] = pd.to_datetime(df.date_format).dt.year


def add_closeness_adj(df):
    '''
    Adding 1 to a district if it was close to a game, even if no tweets were posted in the district
    :param df: Dataframe after groupby
    :return: Additional observations with 0 if there was no game in the district, but it was close to a game
    '''
    closeness_away = df[df.close_away > 0]
    #Getting a list of all of the districts that were ever deemed close to a certain team
    closeness_away = closeness_away[["district_name", "Away_y"]].drop_duplicates()
    #creating a key by the name of the away team and the district
    closeness_away["close_away_adj"] = 1
    closeness_away['key'] = closeness_away["district_name"] + closeness_away["Away_y"]
    closeness_away = closeness_away[["key", 'close_away_adj']]
    df['key'] = df["district_name"] + df["Away_y"]
    df = pd.merge(df, closeness_away, on='key', how='left')
    #same with home team
    closeness_home = df[df.close_home > 0]
    closeness_home = closeness_home[["district_name", "Home_y"]].drop_duplicates()
    closeness_home["close_home_adj"] = 1
    closeness_home['key'] = closeness_home["district_name"] + closeness_home["Home_y"]
    closeness_home = closeness_home[["key", 'close_home_adj']]
    df['key'] = df["district_name"] + df["Home_y"]
    df = pd.merge(df, closeness_home, on='key', how='left')

    return df

def add_zeros(df, thresh, col_thresh="tot"):
    '''
    Adding the value 0 for days and locations where there were no tweets
    :param df: DF after groupby of all tweets with locations
    :param thresh: Distance to be considered close
    :param col_thresh:  If necessary, threshold for minimum number of tweets ever posted in a district (Default TOT)
    :return:
    '''
    df_tot = df[df[col_thresh] == 1].groupby(["district_name"]).count()

    cities_with_thresh = list(df_tot[df_tot.date_format > thresh].index)

    df_with_thresh = df[df["district_name"].isin(cities_with_thresh)]
    locations = df_with_thresh["district_name"].unique()
    dates = df_with_thresh['date_format'].unique()

    #
    mind = pd.MultiIndex.from_product([locations, dates], names=["district_name", 'date_format'])

    df_with_zeros = df_with_thresh.set_index(["district_name", 'date_format']).reindex(mind,
                                                                                            fill_value=0).reset_index()
    df_with_zeros["weekday"] = pd.to_datetime(df_with_zeros.date_format).dt.dayofweek
    df_with_zeros["day"] = pd.to_datetime(df_with_zeros.date_format).dt.day
    df_with_zeros["month"] = pd.to_datetime(df_with_zeros.date_format).dt.month
    df_with_zeros["year"] = pd.to_datetime(df_with_zeros.date_format).dt.year
    soccer_file = df_with_thresh[["date_format", "HomeGoals", "AwayGoals", "Home", "Away", "FTR","day_after"]].fillna(
        "").drop_duplicates()
    df_with_zeros=pd.merge(df_with_zeros,soccer_file,how='left',on='date_format')

    df_with_zeros = add_closeness_adj(df_with_zeros)

    return df_with_zeros

def create_file_for_stata(path,close_thresh,target):
    '''
    Creating the file to be used on stata
    :param path: Path to folder where the files are saved
    :param close_thresh: The distance where we define a game as "close to the stadium"
    :param target: Target folder where the files are to be saved
    :return:
    '''
    initial_file = create_groupby_date_location(path,close_thresh)

    add_time(initial_file)
    dataset = add_zeros(initial_file, 0)
    add_military_operations(dataset)
    dataset.to_csv(target,index=False)



def main():

    for i in [30,25,20,15]:
        create_file_for_stata(PATH,i,TARGET+str(i)+"_km.csv")

if __name__ == '__main__':
    main()
