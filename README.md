# BVGHackaton2018

An augmented Reality Assistant that leverages the data provided by the BeaconInside SDK for indoor positioning.

## Inspiration

Have you ever been to a new place and as you got off the train you had no idea in which direction to proceed? Maybe you even went in the wrong direction and ran late?
Wouldn't it be handy to have an interactive navigation through the train station?

Indoor navigation with augmented reality technology is already possible. 

https://www.youtube.com/watch?v=jGJmP7D09MY

In addition floor plans of most of Berlins stations do exist.

But no one has brought them together yet.

## What is our vision?

We want to create a tool for everyone that navigates reliably to the next platform, their connecting service or any other place of interest. This indoor navigation tool uses beacons to detect your current location and displays instructions via augmented reality on your screen.

## How we built it

We used Beacon Insides beacon SDK from their GitHub repo (https://github.com/beaconinside/hackathon) to build an iOS app which extracts the strength of the beacon signal. Based on this Information we then compute the current location of the user and display naviation instructions on screen.

## Accomplishments that we're proud of

Managed to pick up the beacon Signals via the iOS app as well as Raspberry Pi.

## What we learned

We gained a better understanding of the needs and prerequisites to set up an augmented reality environment. The implementation of beacon inside repo was smooth and seamless.

## What's next for Train Station Indoor Maps

360° footage of all train stations is Berlin is needed which will then have to be integrated into the app. Moreover, stations will have to be equipped with beacons to detect the user's location.
