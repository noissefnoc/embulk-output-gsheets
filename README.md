# Google Sheets output plugin for Embulk

Dump records to [Google Sheets](https://sheets.google.com/).

## Overview

* **Plugin type**: output
* **Load all or nothing**: no
* **Resume supported**: no
* **Cleanup supported**: yes

## Configuration

- **spreadsheet_id**: Google Sheets' ID (string, required)
    - if sheets url is `https://docs.google.com/spreadsheets/d/hoge/edit#gid=0` then `spreadsheet_id` is `hoge` ) 
- **sheet_name**: Sheet Name (string, required)
- **client_secrets_path**: Path to client_secrets.json (string, required)
- **credential_path**: Path to credential file (string, default: `~/.credentials/embulk-output-gsheets.yml`)
- **application_name**: Application name pass to Google (string, default: `embulk-output-gsheets`)
- **bulk_num**: Bulk write number of records (integer, default: 200) 
- **with_header**: Write header line (bool, default: true)


## Example

```yaml
out:
  type: gsheets
  spreadsheet_id: SPREADSHEET_ID
  sheet_name: SHEET_NAME
  client_secrets_path: PATH_TO_CLIENT_SECRET_JSON_FILE
```


## Build

```
$ rake
```
