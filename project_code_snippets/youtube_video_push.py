# -*- coding: utf-8 -*-

# Sample Python code for youtube.playlistItems.insert
# See instructions for running these code samples locally:
# https://developers.google.com/explorer-help/guides/code_samples#python

import os

import google_auth_oauthlib.flow
import googleapiclient.discovery
import googleapiclient.errors

scopes = ["https://www.googleapis.com/auth/youtube.force-ssl", "https://www.googleapis.com/auth/youtube"]
current_folder = os.path.dirname(os.path.abspath(__file__))
client_secrets = f"{current_folder}\client_secret_85121827688-kqiuubg9qet0e9c3mmi4lqnnrh2kvsfh.apps.googleusercontent.com.json"

#################################

video_list = ['video_id']
################################
def main(videos,playlist_id ):
    # Disable OAuthlib's HTTPS verification when running locally.
    # *DO NOT* leave this option enabled in production.
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
   
    for i in videos:
        try:
            request = youtube.playlistItems().insert(
                part="snippet",
                body={
                "snippet": {
                    "playlistId": playlist_id,
                    "position": 0,
                    "resourceId": {
                    "kind": "youtube#video",
                    "videoId": i
                    }
                    }
                    }
            )
            response = request.execute()
        except:
            print('Video not found')

    print(response)


main(video_list,'<playlist_id>')