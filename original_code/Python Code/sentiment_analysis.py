import pandas as pd
import os
import tweetnlp
import tqdm

'''
This script takes the raw files from the raw files folder and adds a sentiment analysis to each file
Then, it saves the files with the sentiment analysis in a new folder
'''



FOLDER = r"YOURPATH\\"
MATCHES = "not used" # not used
SENTIMENT=r"YOURPATH\sentiment\\"




def sort_date_twitter(df):
    '''
    Sorting the dates of the tweets as a pandas datetime
    :param df:
    :return:
    '''
    df["year"] = (df["created_at"].apply(lambda x: x[0:4]))
    df["month"] = (df["created_at"].apply(lambda x: x[5:7]))
    df["day"] = (df["created_at"].apply(lambda x: x[8:10]))
    df['date_format'] = pd.to_datetime(dict(year=df.year, month=df.month, day=df.day))
    return df





def sort_matches(df):
    '''
    Sorting the dates of the matches - depricated
    :param df: Pandas DataFrame
    :return: file
    '''
    df["year"] = (df["Date"].apply(lambda x: x[0:4]))
    df["month"] = (df["Date"].apply(lambda x: x[5:7]))
    df["day"] = (df["Date"].apply(lambda x: x[8:10]))
    df['date_format'] = pd.to_datetime(dict(year=df.year, month=df.month, day=df.day))
    return df

def add_sentiment(df):
    '''
    Adding sentiment analysis to a pandas file
    :param df: DataFrame
    :return: DF with sentiment
    '''
    model = tweetnlp.load_model('sentiment')
    sentiment=[]
    tweets = df.text
    with tqdm.tqdm(tweets) as pbar:
        for tweet in tweets:
            sentiment.append(model.sentiment(tweet, return_probability=True))
            pbar.update()
    df['positive']=[i["probability"]["positive"] for i in sentiment]
    df['neutral']=[i["probability"]["neutral"] for i in sentiment]
    df["negative"] =[i["probability"]["negative"] for i in sentiment]
    return df


def add_sentiment_to_all(folder,sentiment):
    '''
    Adding sentiment to all files
    :param folder: Path to folder with raw files
    :param sentiment: Path to folder with sentiment
    :return: File with sentiment analysis
    '''
    files = os.listdir(folder)
    dfs = [pd.read_csv(folder+i) for i in files]
    for i in range(0,len(files)):
        df = sort_date_twitter(dfs[i])
        df = add_sentiment(df)
        df.to_csv(sentiment+files[i],index=False)



def main():
    add_sentiment_to_all(FOLDER,SENTIMENT)

if __name__ == '__main__':
    main()

