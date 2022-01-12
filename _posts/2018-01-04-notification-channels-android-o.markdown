---
layout: post
title:  "Notification Channels in Android Oreo"
date:   2018-02-06 20:20:02
description: Prepare your app for Android Oreo targets by implementing notification channels
excerpt: "Prepare your app for Android Oreo targets by implementing notification channels"
permalink: /posts/notification-channels-android-o
tags: [android oreo, tutorial, notification channels, notification categories]
---


In (not-so) recent news, Google is going to enforce that all apps target SDK 26 (Android Oreo) by late 2018, in order to ensure security and improved performance in apps. You can read more about the announcement [here](https://android-developers.googleblog.com/2017/12/improving-app-security-and-performance.html).

Now, it's pretty easy to target API 26, but there's no gurantee that your app will function as it used to by just changing the `targetSdkVersion` value in your `build.gradle` file.

This post looks specifically at one of the new things introduced in Android Oreo, and how targeting API 26 will affect your app, and notifications - notification channels (or categories).

TL;DR
-----

Your app will stop sending notifications to the users if you target API 26 and you don't implement notification channels.

What are Notification Channels?
-----

In Android O, notification channels are somewhat like groups or categories of notifications - say you're building a social networking app, the channels can be "activity" - likes, or comments on your posts, "messages", etc. In fact, in the settings of your app, the user sees channels as "categories" as seen in the screenshot below.

<!-- Insert notification settings screenshot here -->
<p align="center">
	<img src="/images/notification-channels-android-o.png"
  alt="Notification Settings screenshot showing different notification categories">
</p>



With the introduction of notification channels, users can get a fine control of what they want to be notified about. They can specifically turn off notifications for a certain channel, specify the importance as well as the preferred sound for a particular category of notifications and determine whether or not to override DND (Do not disturb)

Implementing Notification Channels
-----

### Creating notification channels

These notification channels are created at runtime, so they can be dynamically changed to fit the requirements of your the user. For example, if a user subscribes to group chat for example, you can create a channel matching that particular group, and when they leave the group, you can remove the notification channel.

So how then does one add channels to notifications? At the simplest level, one needs to create a channel with a unique name and ID and a level of importance. The uniqueness of the name and ID only refers to your app package. The notification manager then does the creation of the channel with whatever settings you specify. Typically the creation code looks like:

```kotlin
val privateMessagesChannel = NotificationChannel(
                    PRIVATE_MESSAGES_CHANNEL_ID,
                    context.getString(R.string.pm_channel_name),
                    NotificationManager.IMPORTANCE_DEFAULT)

notificationManager.createNotificationChannel(privateMessagesChannel)
```
It's worthy of note that you can also create channel groups. This is useful in scenarios where you have multiple accounts or profiles so you can group the notification channels per account/profile.

You can specify further customizations for the channel you have created. For example, you can specify the light colors, vibration pattern etc. for the channel as shown below:

```kotlin
with(privateMessagesChannel) {
    lightColor = Color.RED
    enableVibration(true)
    vibrationPattern = longArrayOf(100, 200, 300, 400)
}
```

### Sending notifications for a notification channel

Now that we've created the channel, next step is to actually specify the channel whenever we want to show a notification and that is done when creating a new notification.
Specifying a channel for the notification looks like:

```kotlin
val notification = NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.ic_notification_small)
                .setContentTitle(context.getString(R.string.notif_pm_title))
                .setContentText(message)
                /**
                 * further notification customizations
                 */
                .setChannelId(PRIVATE_MESSAGES_CHANNEL_ID)
                .build()
        notificationManager.notify(PM_NOTIFICATION_ID, notification)
```
The part of the code above that sets the channel is `.setChannelId()`. Without this line, if you're targeting Android O and above, your notification will not be shown to the user.

### Updating/reading notification channels settings

After creating notification channels, the ability to control is left to the user. They can turn off notifications, change priority, lights and vibration settings etc. for any channel they desire. However, it is possible to programmatically read the current channel settings. You may need this, so that you can present the status of the notification channel to your user. For example, if the user has turned off notifications for a certain group
chat, you may display a "mute" icon next to the group details or somewhere it's visible to the user. 

It's important not to make this intrusive in anyway or obstruct users from going about their normal activities in the app because it defeats the purpose of giving users the power to control the settings for the channel.

To read the notification channel details, you need to get a reference to the notification channel, and query the settings you desire.

```kotlin
val pmNotificationChannel = notificationManager.getNotificationChannel(PRIVATE_MESSAGES_CHANNEL_ID)

val channelIsBlocked = pmNotificationChannel.importance == NotificationManager.IMPORTANCE_NONE

if (channelIsBlocked) {
	// do something unintrusive to make user aware that they blocked the notification
	// you should also provide a way to make them go to the channel settings
}
```
The code block above shows how we can check for the importance setting for the channel, we can do similar for lights, vibration, and other settings

To provide a well rounded experience, it is advisable to help users access the notification settings where they can update their notifications. You can place this somewhere in your settings menu. There is an
intent available for the notification settings, and constructing code looks like:

```kotlin
val notificationSettingsIntent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
notificationSettingsIntent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
startActivity(notificationSettingsIntent)
```

### Deleting notification channels
So let's assume that a user has unsubscribed from a previous conversation that a channel was created for. You will have to delete the channel. Deleting is quite straightforward. To do this, one needs to do something like:

```kotlin
notificationManager.deleteNotificationChannel(PRIVATE_MESSAGES_CHANNEL_ID)
```

Extra
-----

There are some additional thoughts & questions that come up regarding notification channels. Questions like - 

* When is the best time to set up notification channels? On app start? When the user profile is ready? Just before showing the notification? Dan Lew has some thoughts about this: [http://blog.danlew.net/2017/09/06/working-with-android-notification-channels/](http://blog.danlew.net/2017/09/06/working-with-android-notification-channels/)
* What if I really really need to show the notification to the user? - We have this covered in this post. Final decision about notification settings is up to the user, once the channels have been created and a notification posted to the channel. If the user modifies the setting to one that doesn't make them fully enjoy the app, you can unobtrusively make them aware of this - using a dismissable card or something of that nature. I personally won't advice using an alert or complete breakdown of the app.
* What about pre-O devices? If you support devices below API level 26, you will probably get a lot of lint warnings as you implement this. NotificationManagerCompat doesn't (yet) contain methods to create, update & delete the channels. This suggests that you may need to have a [`NotificationManager`](https://developer.android.com/reference/android/app/NotificationManager.html) to handle these things for API level 26+, and [`NotificationManagerCompat`](https://developer.android.com/reference/android/support/v4/app/NotificationManagerCompat.html) for older APIs (depending on how far back your minSdk is).
Also, related to this, the [`NotificationCompat.Builder`](https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context,%20java.lang.String)) already adds support for setting channel ids to which notifications will be posted.

### Further reading
Here are some resources that may come in handy for further reading on notification channels:
* [https://developer.android.com/guide/topics/ui/notifiers/notifications.html#ManageChannels](https://developer.android.com/guide/topics/ui/notifiers/notifications.html#ManageChannels)
* [https://codelabs.developers.google.com/codelabs/notification-channels-kotlin/#0](https://codelabs.developers.google.com/codelabs/notification-channels-kotlin/#0)
* [http://blog.danlew.net/2017/09/06/working-with-android-notification-channels/](http://blog.danlew.net/2017/09/06/working-with-android-notification-channels/)

Summary
-----

In conclusion, the new notification channels in Android provide an improved experience for users - in terms of gaining more control over notifications, and this also helps us developers to be more decent in our use of notifications. At the end of the day, it's a win-win situation.

Finally, remember that come August 2018 for new apps and November for app updates, you will be required to target Android O (API level 26) or higher. And as a result, this will require you to implement notification channels if you show notifications in your app.

If you want to see some more code, I have a demo project with some of these implementations available on Github, check it out here: [https://github.com/segunfamisa/android-notification-channels-demo](https://github.com/segunfamisa/android-notification-channels-demo) 

Thanks to [Moyin](https://medium.com/@moyinoluwa) for helping to review the post.

Thanks for reading this post. Please feel free to give feedback, suggestions, corrections etc. Also, if you found the post useful, please share and/or leave a comment.

Thank you.
