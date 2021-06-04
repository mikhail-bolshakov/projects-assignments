# -*- coding: utf-8 -*-

# Sample Python code for youtube.playlists.list
# See instructions for running these code samples locally:
# https://developers.google.com/explorer-help/guides/code_samples#python

import os
import csv
import google_auth_oauthlib.flow
import googleapiclient.discovery
import googleapiclient.errors

scopes = ["https://www.googleapis.com/auth/youtube.readonly"]

current_folder = os.path.dirname(os.path.abspath(__file__))
client_secrets = f"{current_folder}\client_secret.json"
def main():
    
    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

    api_service_name = "youtube"
    api_version = "v3"
    client_secrets_file = client_secrets

    # Get credentials and create an API client
    flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(
        client_secrets_file, scopes)
    credentials = flow.run_console()
    youtube = googleapiclient.discovery.build(
        api_service_name, api_version, credentials=credentials)

    request = youtube.playlists().list(
        part="id, snippet",
        channelId="<channelId>"
    )
    response = request.execute()
    playlist_dic = {}
    videos_dic = {}
    for i in response['items']:
        playlist_dic[i['snippet']['title']] = i['id']

    for key, playlist_id in playlist_dic.items():
        request = youtube.playlistItems().list(
            part="contentDetails,id",
            maxResults=1000,
            playlistId=playlist_id
        )
        response = request.execute()
        playlist = []
        for num, i in enumerate(response['items']):
            
            playlist.append('https://www.youtube.com/watch?v='+i['contentDetails']['videoId'])
        
        videos_dic[key] = playlist
    return videos_dic

with open('playlists_url.csv', 'w', newline = '') as outcsv:
    for key,value in main().items():
        wr = csv.writer(outcsv)
        wr.writerow([key])
        for i in value:
            wr.writerow([i])