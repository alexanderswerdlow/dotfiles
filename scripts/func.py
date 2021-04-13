import subprocess, re, fire, time, datetime, os, shutil, configparser, shlex

def exec(command: str, combine_output: bool = True, timeout: int=None, raw_process: bool = False):
    if raw_process:
        return subprocess.run(shlex.split(command), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=timeout)
    elif combine_output:
        return subprocess.run(shlex.split(command), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=timeout).stdout.rstrip()
    else:
        p = subprocess.run(shlex.split(command), capture_output=True, text=True, timeout=timeout)
        return p.stdout, p.stderr

def change_network_order(preferred_service):
    orig_services = exec(f'networksetup -listnetworkserviceorder', combine_output=False)[0].splitlines()
    services = [r.group('name') for r in (re.search(r'\(\d+\) (?P<name>.*)', l) for l in orig_services) if r is not None]
    if preferred_service in services:
        services.insert(0, services.pop(services.index(preferred_service)))
        new_order = " ".join('"{0}"'.format(s) for s in services)
        exec(f'networksetup -ordernetworkservices {new_order}')

def connect_vpn(vpn_name):
    def internet_working():
        try:
            return re.search("succeeded", exec("nc -G 1 -z www.google.com 80", timeout=5))
        except subprocess.TimeoutExpired:
            return None

    vpn_status = exec(f'networksetup -showpppoestatus "{vpn_name}"')
    if vpn_status == "connected":
        while not internet_working():
            print(f"VPN Connected — No Internet — {datetime.datetime.now()}")
            exec(f'networksetup -disconnectpppoeservice \"{vpn_name}"')
            time.sleep(2.0)
            exec(f'networksetup -connectpppoeservice "{vpn_name}"')
            time.sleep(2.0)
        print(f"VPN Connected — Internet Working — {datetime.datetime.now()}")
    else:
        print(f"VPN not connected — {datetime.datetime.now()}")
        exec(f'networksetup -connectpppoeservice "{vpn_name}"')

def backup_scripts():
    datestr = datetime.datetime.now().strftime("%m-%d-%Y_%H-%M%p")
    h = os.getenv('HOME')
    base_dir = f"{h}/Documents/Programs/Shell/{datestr}"
    shutil.copytree(f"{h}/dotfiles", f"{base_dir}/dotfiles", ignore=shutil.ignore_patterns("plugins"), dirs_exist_ok=True)
    shutil.copytree(f"{h}/bin", f"{base_dir}/bin", dirs_exist_ok=True)

def connect_server():
    config = configparser.ConfigParser()
    config.read(os.environ['SECRETS'])
    for location in config['server']['volumes'].split(','):
        subprocess.run(['osascript', '-e', f'mount volume "{config["server"]["address"]}/{location}"'], timeout=5)

def check_connection():
    home_loc = os.getenv('HOME')
    ping_output = exec(f'ping -c1 google.com', raw_process=True)
    wget_output = exec(f'wget --spider http://example.com', raw_process=True)
    datestr = f'NETWORK CHECK at : {str(datetime.datetime.now())}:'
    with open(f"{home_loc}/tmp/network_log.txt", "a") as file:
        if ping_output.returncode == 0 and wget_output.returncode == 0:
            file.write(f'{datestr} SUCCEEDED\n')
            file.write(f'Ping: {ping_output.stdout}\n')
            file.write(f'Wget: {wget_output.stdout}\n\n')
        else:
            file.write(f'{datestr} FAILED\n')
            file.write(f'Ping: {ping_output.stdout}\n')
            file.write(f'Wget: {wget_output.stdout}\n\n')

if __name__ == '__main__':
    fire.Fire()