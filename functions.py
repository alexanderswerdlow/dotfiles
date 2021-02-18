import subprocess, re, fire, time, datetime, os, shutil

def change_network_order(preferred_service):
    process = subprocess.run(['networksetup', '-listnetworkserviceorder'], capture_output=True, check=True, text=True)
    services = [r.group('name') for r in (re.search(r'\(\d+\) (?P<name>.*)', l) for l in process.stdout.splitlines()) if r is not None]
    if preferred_service in services:
        services.insert(0, services.pop(services.index(preferred_service)))
    process = subprocess.run(['networksetup', '-ordernetworkservices'] + services)


def connect_vpn(vpn_name):
    vpn_status = os.popen(f"networksetup -showpppoestatus \"{vpn_name}\"").read().strip()
    if vpn_status == "connected":
        internet_status = os.popen(f"nc -G 1 -z www.google.com 80 2>&1").read().strip()
        while not re.search("succeeded", internet_status):
            print(f"VPN Connected — No Internet — {datetime.datetime.now()}")
            result = os.popen(f"networksetup -disconnectpppoeservice \"{vpn_name}\"").read()
            time.sleep(1.0)
            result = os.popen(f"networksetup -connectpppoeservice \"{vpn_name}\"").read()
            time.sleep(1.0)
            internet_status = os.popen(f"nc -G 1 -z www.google.com 80 2>&1").read().strip()
            time.sleep(0.1)
        print(f"VPN Connected — Internet Working — {datetime.datetime.now()}")
    else:
        print(f"VPN not connected — {datetime.datetime.now()}")
        result = os.popen(f"networksetup -connectpppoeservice \"{vpn_name}\"").read()

def backup_scripts():
    datestr = datetime.datetime.now().strftime("%m-%d-%Y_%H-%M%p")
    h = os.getenv('HOME')
    base_dir = f"{h}/Documents/Programs/Shell/{datestr}"
    shutil.copytree(f"{h}/dotfiles", f"{base_dir}/dotfiles", ignore=shutil.ignore_patterns("plugins"), dirs_exist_ok=True)
    shutil.copytree(f"{h}/bin", f"{base_dir}/bin", dirs_exist_ok=True)

if __name__ == '__main__':
    fire.Fire()