---
layout: post
title: Improved notifications with Direct reply in Android N
date: 2016-09-25 08:42:45
description: Tutorial on how to implement notifications with direct reply in Android N
permalink: "/posts/notifications-direct-reply-android-nougat"
tags: [android, android studio, tutorial, nougat, notifications]
excerpt: Tutorial on how to implement notifications with direct reply in Android N
comments: true
twitter_card_image: "/img/android-nougat-banner.png"
header_image: /img/android-nougat-banner.png
---

# Introduction

Notifications is one feature that improves at almost every Android update.
From single tap notifications, to actionable notifications, Android N also introduces some new features to Notifications in Android.
Android N introduces direct reply, notification bundling and other cool features.

If you have Android N installed on your device, you may have noticed the new way the notifications
appear. You may also have noticed that you can reply messages in-line right from your notification.
I noticed this behaviour has already been implemented on quite a number of apps including Twitter, Slack, WhatsApp.

This is made possible by *Direct reply*. Direct reply aims to reduce the number of steps between receiving a notification and acting on it.

The image below is direct reply in action on Slack for Android app.

<p align="center">
  <img src="http://i.imgur.com/R8BUkFt.jpg">
</p>

In this post, we will walk through the steps in implementing direct reply in your apps.
I will cover the new notification styles and bundling notifications in another post.


# How it works?
Direct reply makes use of a combination of notification, action and [Remote Input](https://developer.android.com/reference/android/support/v4/app/RemoteInput.html). Once a Remote input is added to a notification, Android knows that it should request for input from the user.
This happens the same way to request for voice input on Android wear 2.0.

# How to implement?

Implementation happens in 3 major steps:

## 1. Add direct reply action
First thing to do, is to add a direct reply action to your notification. To do this, you need to first:

##### a. Build your label using a remote input.

The remote input holds information such as the label to show for the action, and the key
that will be used to retrieve the user input later on.

```java
String replyLabel = getString(R.string.notif_action_reply);
RemoteInput remoteInput = new RemoteInput.Builder(KEY_REPLY)
          .setLabel(replyLabel)
          .build();
```

##### b. Build your notification action
Next step is to build the notification action. This uses the `NotificationCompat.Action` for
backwards compatibility. You will then connect the action with the remote input.

This requires:

  *  An icon,
  *  A label (which we built in the previous step) and,
  *  A [PendingIntent](https://developer.android.com/reference/android/app/PendingIntent.html).

The pending intent is what describes the action that will be taken when the notification action
is clicked. More notes on selecting the pending intent in the next section.

```java
NotificationCompat.Action replyAction = new NotificationCompat.Action.Builder(
                R.drawable.ic_notif_action_reply, replyLabel, getReplyPendingIntent())
                .addRemoteInput(remoteInput)
                .setAllowGeneratedReplies(true)
                .build();
```

##### c. Select the appropriate PendingIntent
The usual next step is to select the appropriate PendingIntent. Now, this is important,
because, the best practices regarding the PendingIntent depends on the OS version of the user.

Direct reply is new in Android N, and Android already handles the UI, so the right
pending intent here will ideally be a Service/IntentService (for a long running background task) or
a BroadcastReceiver, which runs on the UI thread. It also works without unlocking, making the process really fluid for the user.

However, for Android devices running Marshmallow and below (API level 23 and below), it will be more appropriate to use an activity. Since you have to provide your own UI.

Creating a PendingIntent will look like:

```java
Intent intent;
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
    // start a
    // (i)  broadcast receiver which runs on the UI thread or
    // (ii) service for a background task to b executed , but for the purpose of
    // this codelab, will be doing a broadcast receiver
    intent = new Intent(context, NotificationBroadcastReceiver.class);
    intent.setAction(REPLY_ACTION);
    intent.putExtra(KEY_NOTIFICATION_ID, notificationId);
    intent.putExtra(KEY_MESSAGE_ID, messageId);
    return PendingIntent.getBroadcast(getApplicationContext(), 100, intent,
                                            PendingIntent.FLAG_UPDATE_CURRENT);
} else {
    // start your activity for Android M and below
    intent = new Intent(context, ReplyActivity.class);
    intent.setAction(REPLY_ACTION);
    intent.putExtra(KEY_MESSAGE_ID, messageId);
    intent.putExtra(KEY_NOTIFICATION_ID, notifyId);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    return PendingIntent.getActivity(this, 100, intent,
                                            PendingIntent.FLAG_UPDATE_CURRENT);
}

```


##### d. Build your notification
Next is to build notification and create it. Doing this makes use of the  reply action we built in step b above.
Sample code to implement this is:

```java

NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_notif_smile)
                .setContentTitle(getString(R.string.notif_title))
                .setContentText(getString(R.string.notif_content))
                .setShowWhen(true)
                .addAction(replyAction); // reply action from step b above

NotificationManagerCompat mNotificationManager = NotificationManagerCompat.from(this);
mNotificationManager.notify(mNotificationId, mBuilder.build());
```

## 2. Read input from inline message

Now that we've shown the notification, we now want to read what the user has typed in the
direct reply remote input. Remember, we had to set a key when we created the remote input in step a above, now is the time to use it. It's really easy to do that.

In our broadcast receiver (or Service, if you chose that) we simply add something like:

```java
private CharSequence getReplyMessage(Intent intent) {
    Bundle remoteInput = RemoteInput.getResultsFromIntent(intent);
    if (remoteInput != null) {
        return remoteInput.getCharSequence(KEY_REPLY);
    }
    return null;
}
```

You can then use that method in the onReceive method of your broadcast receiver.

```java
...
@Override
public void onReceive(Context context, Intent intent) {
    if (REPLY_ACTION.equals(intent.getAction())) {
        // do whatever you want with the message. Send to the server or add to the db.
        // for this tutorial, we'll just show it in a toast;
        CharSequence message = getReplyMessage(intent);
        int messageId = intent.getIntExtra(KEY_MESSAGE_ID, 0);

        Toast.makeText(context, "Message ID: " + messageId + "\nMessage: " + message,
                Toast.LENGTH_SHORT).show();
    }
}
```

**Update**

NB: If you happen to be using a broadcast receiver, ensure that your BroadcastReceiver isn't exported.
The reason for this is, if your component (say BroadcastReceiver) is accessible from a 3rd party app,
the app could create fake RemoteInput results and create PendingIntents **without** any user interaction. This could lead to major security issues.

If you're using a BroadcastReceiver, one way to make sure it's only accessible within your app, is to set
`exportable` to `false`

Your BroadcastReceiver will look like this in your AndoridManifest.xml file:

```xml
<receiver
    android:name=".NotificationBroadcastReceiver"
    android:enabled="true"
    android:exported="false" />
```

Thanks [Cketti](https://twitter.com/cketti) for suggesting the update

## 3. Update your notification.
You don't want your remote input to keep spinning forever, so you should update the notification.
It's good practice, to update the notification, instead of outright dismissal. Dismissal leaves the user
wondering whether or not the action was successful or not.

To do that, you need the notification id to be the same as the one currently showing.

Sample code:

```java
NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);

NotificationCompat.Builder builder = new NotificationCompat.Builder(this)
        .setSmallIcon(R.drawable.ic_notif_smile)
        .setContentText(getString(R.string.notif_content_sent));

notificationManager.notify(notifyId, builder.build());
```

# Results?

The result of this is something like what we have below.

<p align="center">
  <img src="http://i.imgur.com/epBNyB1.png">
</p>

# More code?

If you want to see more code, I've created a demo project on Github. Check it out here:
[https://github.com/segunfamisa/android-nougat-notification](https://github.com/segunfamisa/android-nougat-notification). Please remember to star the repo :D. Thanks.

# References and further reading
  *  [https://developer.android.com/guide/topics/ui/notifiers/notifications.html#direct](https://developer.android.com/guide/topics/ui/notifiers/notifications.html#direct)
  * [http://android-developers.blogspot.com.ng/2016/06/notifications-in-android-n.html#directreply](http://android-developers.blogspot.com.ng/2016/06/notifications-in-android-n.html#directreply)
  * [https://www.youtube.com/watch?v=Zg4v9G-lku8&feature=youtu.be](https://www.youtube.com/watch?v=Zg4v9G-lku8&feature=youtu.be)


Hey, thank you for reading!
If you have any comments/suggestions or corrections, feel free to drop a comment below or [tweet](https://twitter.com/segunfamisa) at me.

Please share if you found this useful.

Thanks.

Cheers,

Segun.
