import requests, json, datetime, configparser, fire
secrets_file = '../secrets.ini'
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

def update_playlist():
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
    r_library = requests.get(url = "https://api.spotify.com/v1/me/tracks", headers=HEADERS) 
    r_existing_playlist = requests.get(url = f"https://api.spotify.com/v1/playlists/{playlist_id}", headers=HEADERS)

    if not r_library.ok or not r_existing_playlist.ok:
        print("Library/Plaulist request failed")
        exit(1)

    data = {'tracks': []}
    for track in r_existing_playlist.json()['tracks']['items']:
        d = track['track']
        data['tracks'].append({"uri": d['uri']})

    r_delete = requests.delete(url=f"https://api.spotify.com/v1/playlists/{playlist_id}/tracks", headers=HEADERS, data=json.dumps(data))
    if r_delete.ok:
        print(r_delete.json())
    else:
        print("Get Playlist Failed")
        exit(1)

    track_uris_to_add = ''
    for track in r_library.json()['items']:
        dt = datetime.datetime.fromisoformat(track['added_at'].replace("Z", "+00:00"))
        days_since = (datetime.datetime.now(datetime.timezone.utc) - dt).total_seconds() / 86400.0
        if days_since <= 60:
            track_uris_to_add += f"{track['track']['uri']},"

    r_put_new_tracks = requests.put(url=f"https://api.spotify.com/v1/playlists/{playlist_id}/tracks", headers=HEADERS, params={'uris': track_uris_to_add})
    if r_put_new_tracks.ok:
        print(r_put_new_tracks.json())
    else:
        print("Put songs into playlist failed")
        exit(1)

    print("Playlist Update Sucessful: " + datetime.datetime.now().strftime("%m/%d/%Y, %H:%M:%S"))

if __name__ == '__main__':
  fire.Fire()