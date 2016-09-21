---
layout: post
title: Crash reporting in Firebase
date: 2016-05-26 12:05:30
description: Exploring the new crash reporting feature of Firebase
permalink: "/posts/firebase-crash-reporting"
tags: [android, firebase, crash reporting]
excerpt: Exploring the new crash reporting feature of Firebase
twitter_card_image: "/img/firebase-icon.png"
comments: true
published: true
---

<p align="center">
	<img src="/img/firebase-icon.png">
</p>

**Update:** (21st of September, 2016)  
Since publication of this post, Firebase has changed and evolved, and this post has been updated to the new state of things.

Last week, at [Google I/O](https://events.google.com/io2016/), Google announced a
number of interesting new features in Firebase. The new Firebase is said to be a [_"Unified app platform for mobile developers"_](https://firebase.googleblog.com/2016/05/firebase-expands-to-become-unified-app-platform.html)
adding new tools to help develop faster, improve app quality, engage users and monetize apps. You
can check out this intro video [here](https://youtu.be/fgT6r4f9Apc).

Some of the new features in the Firebase upgrade include:  
  1. Firebase Analytics.  
  2. Firebase Cloud Messaging.  
  3. Firebase Test Lab and Crash Reporting.  
  4. Firebase Notifications, Dynamic Links, App Indexing, AdWords, Firebase Invites etc  

I've been playing around the new product and it's been amazing. In this post, I'm
going to show you how to use Firebase for Crash reporting in order to improve the
quality of apps that you ship.

## How to use?
The new Firebase works with the new Google Play Services 9.0, and to use it in Android Studio,
you need to follow these steps:  

### Setup Firebase

#### 1. Pre-requisites
Ensure your development environment meets the pre-requisite requirements. The Pre-requisites as seen [here](https://firebase.google.com/docs/android/setup#prerequisites) are:

  * An Android device running Google Play services 9.0.0 or later  
  * The Google Play services SDK from the Android SDK Manager  
  * Android Studio 1.5 or higher  
  * An Android Studio project and its package name.

#### 2. Add Firebase to your app
Next step is to add Firebase to your app. To do this, you need to create a project
on the [Firebase console](https://console.firebase.google.com/).  

  * Click on **Create New Project** (if you're starting a new project) or **import Google Project**
if you're importing an existing project, and follow through the steps.  
  * Now, within your app, click on click on **Add Firebase to your Android app**.  

You'll be prompted to add your package name, and also to download a config file.
This is the usual google-services.json file. Be sure to add it to your app module's directory.
(e.g /app)

#### 3. Add the SDK to your app
To use Firebase in your app, you need to add and setup the SDK within your Android app.  
First, include the following lines to your root-level `build.gradle` file:

```groovy
buildscript {
    // ...
    dependencies {
        // ...
        classpath 'com.google.gms:google-services:3.0.0'
    }
}
```

And then at your app-module's `build.gradle` file, apply the google services plugin at
the bottom of the file.  
Your `build.gradle` should look like this:

```groovy
apply plugin: 'com.android.application'

android {
  // ...
}

dependencies {
  // ...
  compile 'com.google.firebase:firebase-crash:9.4.0'
}

// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
```


### Reporting crashes
Firebase Crash reporting automatically reports fatal errors (unhandled exceptions) once the dependency has been added and configured.

It requires **NO** line of code.

### Report non-fatal exceptions.
Firebase allows you to manually report handled non-fatal (i.e exceptions that do not cause app crash).
It's always good to report any errors that happen, whether or not they cause a crash

```java
FirebaseCrash.report(new Exception("My first Firebase non-fatal error on Android"));
```

After a few minutes (it now takes about 2 minutes), the crash will appear on the console dashboard looking like:

<p align="center">
	<img src="/img/firebase-crash-dashboard.png">
</p>

### Creating logs with Firebase
There are other interesting things to do with Firebase crash reporting.

You can create custom logs for events in the reports. Usually, when you get a crash in your app, the next thing you want to find out is, what the user was trying to do right?
Well, creating logs make that easy to do. You can create a log using a line like:

```java
    FirebaseCrash.log("MainActivity started");
```

You can also make that log show on your logcat, use:

```java
    FirebaseCrash.logcat(Log.DEBUG, "TAG", "MainActivity started");
```

### Error Clusters
One really cool thing about Firebase crash reporting is the _Cluster_ feature. Basically,
firebase arranges errors in clusters of similar stack traces and by the severity of impact on your users.

Essentially, it groups by whether or not they are "fatal" errors and whether or not they have similar stack traces. This makes easy overview and prioritising possible.

### Proguard Mappings
Firebase allows you upload your proguard mappings if you have used proguard to secure your app.
This will enable Firebase handle the deobfuscation of crash reports, so that you can make sense out of it.

### Issues?
Firebase crash reporting is still in Beta, so, there are definitely some issues for now,
and I hope they continue to improve the product.

  * While debugging my test app while writing this post, I noticed something strange, the
crash reporting seems to be a separate process, as seen in the screenshot below:

<p align="center">
	<img src="/img/firebase-background-process.png">
</p>

This may lead to some concurrency issues, and It's filed under the known issues here [https://firebase.google.com/docs/crash/android#known-issues](https://firebase.google.com/docs/crash/android#known-issues)

### Closing.
In summary, I think the Firebase crash reporting is a pretty neat feature of the new Firebase product,
and I look forward to it getting more matured, and stable.

I intend to try out the other new parts of Firebase and share my findings.

If you have thoughts, suggestions, or corrections to share, please feel free to drop a comment below or tweet at [me](https://twitter.com/segunfamisa) :)


Sincerely,  
Segun.
