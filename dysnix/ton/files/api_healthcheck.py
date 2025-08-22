
import socket
import requests
import sys

def is_port_open(host, port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.connect((host, port))
            return True
        except (socket.timeout, ConnectionRefusedError):
            return False

def check_url(url):
    try:
        response = requests.get(url)
        return response.status_code == 200
    except requests.RequestException:
        return False

def main():
    host = '127.0.0.1' 
    port = 8081
    url = f'http://{host}:{port}/getMasterchainInfo' 

    if not is_port_open(host, port):
        print(f"Port {port} on {host} is not open.")
        sys.exit(1)

    if not check_url(url):
        print(f"URL {url} did not return status code 200.")
        sys.exit(1)

    print(f"Port {port} on {host} is open and URL {url} returned status code 200.")

if __name__ == "__main__":
    main()