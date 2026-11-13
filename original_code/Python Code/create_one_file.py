from sentiment_analysis import add_sentiment_to_all
from stadiums import runtime
from districts import add_district
from creating_dataset_from_tweets import create_file_for_stata

'''
Creating a file from the tweets. Make sure that the magic keys match the scripts and that the folders are set up
correctly
'''

NULL_VALUE = ""
FOLDER = r"YOURPATH\twitter_files\\"
SENTIMENT_FOLDER = r"YOURPATH\sentiment\\"
STADIUMS = r"YOURPATH\stadiums\games_stadiums.csv"
COORDS_FOLDER=r"YOURPATH\sorted_coords\\"
GEO_PATH = r"YOURPATH\uk_geography\\"
DISTRICTS = r"YOURPATH\districts\\"
TARGET_FOLDER= r"YOURPATH\final_files\\"




def main():
    #add_sentiment_to_all(FOLDER,SENTIMENT_FOLDER)
    runtime(SENTIMENT_FOLDER,STADIUMS,COORDS_FOLDER)
    print("stage_2")
    add_district(GEO_PATH,COORDS_FOLDER,DISTRICTS)
    print("stage_3")
    for i in [25,20,15]:
    # for i in [10,5]:
        create_file_for_stata(DISTRICTS,i,TARGET_FOLDER+str(i)+"km.csv")

if __name__ == '__main__':
    main()
#17:08 initial runtime 26/03/2023
#22:05 27/03/2023
