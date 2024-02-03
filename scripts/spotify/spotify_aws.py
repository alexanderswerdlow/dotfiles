import requests
import json, datetime, configparser, os
secrets_file = 'secrets.ini'
config = configparser.ConfigParser()
config.read(secrets_file)
sp = config['spotify']

def update_auth():
    redirect_uri = 'https://google.com'
    params = {
    'redirect_uri': redirect_uri, 'response_type': 'code', 'client_id': sp['client_id'],
    'scope' : 'user-read-private user-read-email playlist-read-private playlist-modify-public playlist-modify-private user-library-modify user-library-read user-read-email user-read-private user-read-recently-played user-top-read user-read-playback-position user-read-playback-state user-modify-playback-state user-read-currently-playing'
    }

    r = requests.get(url='https://accounts.spotify.com/authorize', params=params)
    if r.ok:
        print(r.url)

    code = input("Enter the url in the browser ").split("=",1)[1] 

    r_auth = requests.post(url='https://accounts.spotify.com/api/token', data={'grant_type': 'authorization_code', 'redirect_uri': redirect_uri, 'code': code, 'client_id': sp['client_id'], 'client_secret': sp['client_secret']})
    if r_auth.ok:
        config.set('spotify', 'refresh_token', r_auth.json()['refresh_token'])
        with open(secrets_file, 'w') as configfile:
            config.write(configfile)
    else:
        print("Code Auth Failed")
        print(r_auth.json())
        exit(1)

def update_discover_weekly():
    r_auth_refresh = requests.post(url='https://accounts.spotify.com/api/token', data={'grant_type': 'refresh_token', 'refresh_token': sp['refresh_token'], 'client_id': sp['client_id'], 'client_secret': sp['client_secret']})
    if r_auth_refresh.ok:
        token = r_auth_refresh.json()['access_token']
    else:
        print("Refresh Auth Failed")
        print(r_auth_refresh.json())
        exit(1)

    playlist_id_archive = sp['discover_archive_id'].split(':')[-1]
    playlist_id_weekly = sp['discover_weekly_id'].split(':')[-1]
    HEADERS = {"Accept":"application/json", "Content-Type":"application/json", "Authorization":f"Bearer {token}"}
    r_discover_archive = requests.get(url = f"https://api.spotify.com/v1/playlists/{playlist_id_archive}", headers=HEADERS, params={'limit' : 50})
    r_discover_weekly = requests.get(url = f"https://api.spotify.com/v1/playlists/{playlist_id_weekly}", headers=HEADERS, params={'limit' : 50})

    if not r_discover_archive.ok or not r_discover_weekly.ok:
        print("Discover Library/Playlist request failed")
        exit(1)

    total_archive = int(r_discover_archive.json()['tracks']['total'])
    archive_offset = total_archive - 40 if total_archive > 40 else 0
    r_discover_archive = requests.get(url = f"https://api.spotify.com/v1/playlists/{playlist_id_archive}/tracks", headers=HEADERS, params={'limit' : 50, 'offset' : archive_offset})
    old_uris = set()
    for track in r_discover_archive.json()['items']:
        d = track['track']
        old_uris.add(track['track']['uri'])

    new_uris = set()
    for track in r_discover_weekly.json()['tracks']['items']:
        new_uris.add(track['track']['uri'])

    to_add = new_uris - old_uris

    print(f'Old: {len(old_uris)}, New: {len(new_uris)}, To Add {len(to_add)}: {to_add}')

    if not to_add:
        print('Exiting early. No changes')
        return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
        }

    data_to_add = {'uris': []}
    for uri in to_add:
        data_to_add['uris'].append(uri)

    r_put_new_tracks = requests.post(url=f"https://api.spotify.com/v1/playlists/{playlist_id_archive}/tracks", headers=HEADERS, data=json.dumps(data_to_add))
    if r_put_new_tracks.ok:
        print(r_put_new_tracks.json())
    else:
        print(f"Put songs into playlist failed: {r_put_new_tracks}")
        exit(1)

    print("Discover Weekly Update Sucessful: " + datetime.datetime.now().strftime("%m/%d/%Y, %H:%M:%S"))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


def lambda_handler(event, context):
    update_discover_weekly()
    print('Finished Discover')
    r_auth_refresh = requests.post(url='https://accounts.spotify.com/api/token', data={'grant_type': 'refresh_token', 'refresh_token': sp['refresh_token'], 'client_id': sp['client_id'], 'client_secret': sp['client_secret']})
    if r_auth_refresh.ok:
        token = r_auth_refresh.json()['access_token']
    else:
        print("Refresh Auth Failed")
        print(r_auth_refresh.json())
        exit(1)

    playlist_id = sp['playlist_id'].split(':')[-1]
    HEADERS = {"Accept":"application/json", "Content-Type":"application/json",
    "Authorization":f"Bearer {token}"}
    r_library = requests.get(url = "https://api.spotify.com/v1/me/tracks", headers=HEADERS, params={'limit' : 50}) 
    r_existing_playlist = requests.get(url = f"https://api.spotify.com/v1/playlists/{playlist_id}", headers=HEADERS)

    if not r_library.ok or not r_existing_playlist.ok:
        print("Library/Playlist request failed")
        exit(1)

    
    old_uris = set()
    for track in r_existing_playlist.json()['tracks']['items']:
        d = track['track']
        old_uris.add(track['track']['uri'])

    new_uris = set()
    for track in r_library.json()['items']:
        dt = datetime.datetime.fromisoformat(track['added_at'].replace("Z", "+00:00"))
        days_since = (datetime.datetime.now(datetime.timezone.utc) - dt).total_seconds() / 86400.0
        if days_since <= 120:
            new_uris.add(track['track']['uri'])

    to_delete = old_uris - new_uris
    to_add = new_uris - old_uris

    print(f'To Delete: {to_delete}')
    print(f'To Add: {to_add}')

    if not to_delete or not to_add:
        print('Exiting early. No changes')
        return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
        }

    data_to_delete = {'tracks': []}
    for uri in to_delete:
        data_to_delete['tracks'].append({"uri": uri})

    data_to_add = {'uris': []}
    for uri in to_add:
        data_to_add['uris'].append(uri)

    r_delete = requests.delete(url=f"https://api.spotify.com/v1/playlists/{playlist_id}/tracks", headers=HEADERS, data=json.dumps(data_to_delete))
    if r_delete.ok:
        print(r_delete.json())
    else:
        print(f"Get Playlist Failed: {r_delete}")
        exit(1)

    r_put_new_tracks = requests.post(url=f"https://api.spotify.com/v1/playlists/{playlist_id}/tracks", headers=HEADERS, data=json.dumps(data_to_add))
    if r_put_new_tracks.ok:
        print(r_put_new_tracks.json())
    else:
        print(f"Put songs into playlist failed: {r_put_new_tracks}")
        exit(1)

    print("Playlist Update Sucessful: " + datetime.datetime.now().strftime("%m/%d/%Y, %H:%M:%S"))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }