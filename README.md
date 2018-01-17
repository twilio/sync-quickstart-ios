# Sync iOS Quickstart Application Overview

## Getting Started

Welcome to the Sync Demo application.  This application demonstrates a basic Tic-Tac-Toe client with the ability to make moves by any number of players, by synchronizing the game state across the clients.

What you'll minimally need to get started:

- A clone of this repository
- A running instance of the backend quickstart of your choice ([Ruby](https://github.com/TwilioDevEd/sync-quickstart-ruby), [Python](https://github.com/TwilioDevEd/sync-quickstart-python), [Node.js](https://github.com/TwilioDevEd/sync-quickstart-node), [Java](https://github.com/TwilioDevEd/sync-quickstart-java), [C#](https://github.com/TwilioDevEd/sync-quickstart-csharp), or [PHP](https://github.com/TwilioDevEd/sync-quickstart-php)) to issue [Access Tokens](https://www.twilio.com/docs/api/sync/identity-and-access-tokens)
- Cocoapods

## Building

### Installing the Cocoapods

Run
```
pod install
```

After the cocoapod installs, be sure you use the new xcworkspace file, not the xcodeproj file, to open the project.

### Wire in your Token Service

Set the value of `urlString` in the SyncManager.swift file to point to a valid Access-Token server. If you're using one of the quickstarts to provide tokens, you'll probably want to use [`ngrok`](http://ngrok.io) to direct a publicly-accessible URL to your localhost service.

```bash
$ ngrok http localhost:4567
```
