# Riddle Me This!

A daily riddle app, inspired by Wordle. This repository contains the mobile client for "Riddle Me This!".

## About

"Riddle Me This!" is a cross-platform mobile application built using Flutter. It connects to a dedicated server for fetching daily riddles. If you're interested in the server-side code, you can find it at [jbayntun/riddle_server](https://github.com/jbayntun/riddle_server).

## Setup and Installation

1. **Dependencies**: Before running the app, you'll need to install the necessary dependencies using:
    ```
    flutter pub get
    ```

2. **Environment Setup**: Create a `.env` file in the root directory of the project and add the following line:
    ```
    RIDDLE_API_SECRET=<MySecret>
    ```
    This token should match the one expected by the server.

3. **Running the App**: Once you've set up the environment, you can run the app in release mode using:
    ```
    flutter run --release
    ```

## Screenshots


The main game screen:
<img src="screenshots/main.jpeg" alt="Start Screen" width="250"/>

Uh oh, wrong guess:
<img src="screenshots/incorrect_guess.jpeg" alt="Incorrect Guess" width="250"/>

Need a hint?
<img src="screenshots/hints.jpeg" alt="Hints" width="250"/>

We have a winner!
<img src="screenshots/win.jpeg" alt="Win Screen" width="250"/>

Or not...
<img src="screenshots/lose.jpeg" alt="Lose Screen" width="250"/>

Some personal stats:
<img src="screenshots/statistics.jpeg" alt="Statistics" width="250"/>

Share with friends: 
<img src="screenshots/share.jpeg" alt="Share Screen" width="250"/>


