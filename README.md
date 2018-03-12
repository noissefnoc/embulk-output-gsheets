# Google Sheets output plugin for Embulk

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)][license]

**WARNING: THIS IS VERY ALPHA VERSION. API OR CONFIGURATION COULD CHANGE.**

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

## Authentication

### Prepare client secret JSON

[OAuth 2](https://developers.google.com/accounts/docs/OAuth2) is used to authorize this application. This library uses [Google API Ruby Client](https://github.com/google/google-api-ruby-client) for authentication and handling Google sheets.

First you create OAuth client and get client secret JSON from [Google Cloud Console](https://console.cloud.google.com/).

1. Go to Google Cloud Console
1. Click 'API Manager'
1. Click 'Create Credentials'
    1. Click 'Create OAuth Client ID'
    1. Choose 'Other'
    1. Fill 'Application name'
1. Get the client id and client secret
    1. Download client secret JSON from download button

Then client secret JSON install to your path. `client_secrets_path` option use this path.


### Get OAuth token from browser

OAuth authorization requires when you run `embulk-output-gsheets` at first time.

1. 'Open the following URL in the browser and enter the resulting code after authorization' log and Authorization URL display on console
1. Copy and paste authorization URL on browser address bar
1. OAuth token displays if authorization success.
1. Copy and paste OAuth token to console and hit enter key


### Utilitie

I'm writing utilitie that provides 'Get OAuth token from browser' section feature by Golang now. It can help preparing OAuth credentials file on multi-platforms.


## Install

This plugin doesn't release rubygems. So clone and build and install step requires.

```
# clone
$ git clone https://github.com/noissefnoc/embulk-output-gsheets.git

# build
$ cd embulk-output-gsheets
$ bundle install
$ bundle exec rake

# install
$ embulk gem install pkg/embulk-output-gsheets-0.1.0.gem
```

## VS.

### kataring/embulk-output-google_spreadsheets

[kataring/embulk-output-google_spreadsheets](https://github.com/kataring/embulk-output-google_spreadsheets) can also embulk-output plugin for Google Sheets. 

| |embulk-output-google_spreadsheet|embulk-output-gsheets|
|:-------|:-------|:----------|
|Language|Java|Ruby|
|Authentication file|p12|JSON|
|Sheets API Version|3|4|
|Latest version|v0.0.2|- (under development)|
|Mode|append|append(*1)|
|Bulk write|No(*2)|yes(*3)|

* 1: intent to imprement `truncate` and `replace` mode
* 2: write once per record
* 3: write once per `bulk_num` option (default: 200)


## Licence

This code is free to use under the terms of MIT licence.


## Author

[Kota Saito](https://github.com/noissefnoc)
