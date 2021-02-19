#!/usr/bin/python3

import subprocess, re, fire, time, datetime, os, shutil, configparser, shlex

def exec(command: str, combine_output: bool = True, timeout: int=None):
    if combine_output:
        return subprocess.run(shlex.split(command), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=timeout).stdout.rstrip()
    else:
        p = subprocess.run(shlex.split(command), capture_output=True, text=True, timeout=timeout)
        return p.stdout, p.stderr

def change_network_order(preferred_service):
    orig_services = exec(f'networksetup -listnetworkserviceorder', combine_output=False)[0].splitlines()
    services = [r.group('name') for r in (re.search(r'\(\d+\) (?P<name>.*)', l) for l in orig_services) if r is not None]
    if preferred_service in services:
        services.insert(0, services.pop(services.index(preferred_service)))
    exec(f'networksetup -ordernetworkservices {services}')

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

if __name__ == '__main__':
    fire.Fire()