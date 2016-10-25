---
layout: post
title: Implementing Bottom Navigation View in your app
date: 2016-10-24 08:42:45
description: Tutorial on how to implement the new bottom navigation view with the support library
permalink: "/posts/bottom-navigation-view-android"
tags: [android, android studio, tutorial, material design, support library]
excerpt: Tutorial on how to implement the new bottom navigation view with the support library
comments: true
twitter_card_image: "/img/android-nougat-banner.png"
header_image: /img/android-nougat-banner.png
---

Sometimes in March 2016, [Luke Wroblewski announced](https://twitter.com/lukew/status/709580252830273537) that the
Bottom navigation bars were now a part of the [material design guidelines](https://material.google.com/components/bottom-navigation.html).
Until then, bottom nav bars were seen as an anti-pattern and were heavily kicked against.

There have been several nice libraries to implement this bottom nav bar design, some of which include:
[https://github.com/roughike/BottomBar](https://github.com/roughike/BottomBar) and
[https://github.com/aurelhubert/ahbottomnavigation](https://github.com/aurelhubert/ahbottomnavigation).

Just last week, Google (through [Nick Butcher](https://twitter.com/crafty/status/789008273949200384))
announced the release of the v25 of the Android Design Support Library which includes the new [BottomNavigationView](https://developer.android.com/reference/android/support/design/widget/BottomNavigationView.html).

In this short post, I'll be showing how to use it in your Android app.

If you are in a hurry, feel free to jump straight to look at the sample code here: [https://github.com/segunfamisa/bottom-navigation-demo](https://github.com/segunfamisa/bottom-navigation-demo)

# Setup
To get started with this, you need the latest version (version 25) of Android SDK & tools (including SDK tools, build-tools, platform-tools, support repository).

# How to use it.

## 1. Add the design support library
First step is to add the design support library to your app-level `build.gradle` file. Example is as shown below:

```groovy
dependencies {
    ...
    compile 'com.android.support:design:25.0.0'
}
```

## 2. Add the BottomNavigationView to your layout
Next step, is to add the actual bottom nav view to the layout. Typically, you will add something like:

```xml
<android.support.design.widget.BottomNavigationView
       android:id="@+id/navigation"
       android:layout_width="match_parent"
       android:layout_height="wrap_content"
       android:layout_gravity="start"
       design:menu="@menu/bottom_nav_items" />
```

The BottomNavigationView uses `design:menu` is a custom attribute that points to the menu resource containing items to be shown on the BottomNavigationView.

There are other custom attributes for the view, including:
  * `design:itemBackground` to set the background of the menu resource
  * `design:itemIconTint` to set the tint which is applied to the item icons.
  * `design:itemTextColor` to set the menu item text colour.

## 3. Define the nav items in the menu resource	 
The BottomNavigationView is used in a very similar way to the [NavigationView](https://developer.android.com/reference/android/support/design/widget/NavigationView.html) because the bottom nav view also uses menu resources to populate items.

To define the items, you need to do so in a menu resource. Let's create one and name it `bottom_nav_items.xml` as we have specified in step 2 above.

A typical content will look like this:

```xml
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/menu_home"
        android:title="@string/menu_home"
        android:icon="@drawable/ic_home_black"
        />
    <item
        android:id="@+id/menu_search"
        android:title="@string/menu_search"
        android:icon="@drawable/ic_search_black"
        />

    <item
        android:id="@+id/menu_notifications"
        android:title="@string/menu_notifications"
        android:icon="@drawable/ic_notifications_black" />
</menu>
```

This means that there will be 3 items, Home, Search and Notifications on the bottom nav view.
We can run the app now, and we'll see our neatly implemented bottom nav view.

## Listening for events on the bottom nav view
Now that we've added the view, we'd love to know when a menu item is clicked right?

To listen for click events on the BottomNavigationView, we just need to call [setOnNavigationItemSelectedListener()](https://developer.android.com/reference/android/support/design/widget/BottomNavigationView.html#setOnNavigationItemSelectedListener(android.support.design.widget.BottomNavigationView.OnNavigationItemSelectedListener) .

Example of how to do this is:

```java

mBottomNav.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                // handle desired action here
                // One possibility of action is to replace the contents above the nav bar
                // return true if you want the item to be displayed as the selected item
                return true;
            }
        });
```

# Want more code?
I've made a 'fuller' demo app demonstrating a use case of the bottom nav view. You can find the code here: [https://github.com/segunfamisa/bottom-navigation-demo](https://github.com/segunfamisa/bottom-navigation-demo) (Please remember to star the repo ;)

Here's what the demo app looks like:
<p align="center">
  <img src="https://imgur.com/y0uv4tX.gif">
</p>

# References
  * [https://developer.android.com/reference/android/support/design/widget/BottomNavigationView.html](https://developer.android.com/reference/android/support/design/widget/BottomNavigationView.html)
  * [https://material.google.com/components/bottom-navigation.html](https://material.google.com/components/bottom-navigation.html)


Hey, thank you for reading!
If you have any comments/suggestions or corrections, feel free to drop a comment below or [tweet](https://twitter.com/segunfamisa) at me.

Please share if you found this useful or know someone that may find it useful.

Thanks.

Segun.
