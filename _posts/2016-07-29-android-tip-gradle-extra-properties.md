---
layout: post
title: Manage Android dependencies versions using gradle extra properties.
date: 2016-07-29 09:05:30
description: Android tip on how to use gradle extra properties to manage dependency versioning
permalink: "/posts/android-gradle-extra-properties"
tags: [android, tip, android studio, gradle]
excerpt: Android tip on how to use gradle extra properties to manage dependency versioning
comments: true
twitter_card_image: "/img/gradle-as.png"
header_image: /img/gradle-as.png
---

This is yet another tip you can use in improving your Android development experience
and speed.

We all love dependencies right? Yes we do!

A typical Android studio project (you can stop reading now if you still use Eclipse 😑 seriously)
has a project level `build.gradle` file and as many module-level `build.gradle` as there are modules.

Dependencies are usually managed at the app-module level, and your app-module `build.gradle` file
can quickly get messy from dependencies. It gets even worse, when you have other modules you reference
in your app-module, each with its own dependencies.

In this post, I'll show a quick way of making things look neat, and easy to maintain.

### Externalize hardcoded values.

Let's say our project's app-module `build.gradle` looks like this:

``` gradle  
apply plugin: 'com.android.application'
android {
    ...
}
...
dependencies {
    // support libraries
    compile 'com.android.support:appcompat-v7:23.4.0'
    compile 'com.android.support:design:23.4.0'
    compile 'com.android.support:percent:23.4.0'
    compile 'com.android.support:cardview-v7:23.4.0'
    compile 'com.android.support:gridlayout-v7:23.4.0'

    //play services
    compile 'com.google.android.gms:play-services-location:9.2.1'
    compile 'com.google.android.gms:play-services-gcm:9.2.1'

    // other dependencies
    ...
}
```

You can see that we've repeated quite a number of versions, including the
android support libraries.

What we want to do is to externalize hardcoded values in our `build.gradle` file by
leveraging gradle's extra properties.

We can extract these hardcoded into an `ext` block. Our `build.gradle` file will now look like this:

``` gradle  
apply plugin: 'com.android.application'
android {
    ...
}
...

ext {
    supportLibraryVersion = '23.4.0'
    playServicesVersion = '9.2.1'
}

dependencies {
    // support libraries
    compile "com.android.support:appcompat-v7:$supportLibraryVersion"
    compile "com.android.support:design:$supportLibraryVersion"
    compile "com.android.support:percent:$supportLibraryVersion"
    compile "com.android.support:cardview-v7:$supportLibraryVersion"
    compile "com.android.support:gridlayout-v7:$supportLibraryVersion"

    //play services
    compile "com.google.android.gms:play-services-location:$playServicesVersion"
    compile "com.google.android.gms:play-services-gcm:$playServicesVersion"

    // other dependencies
    ...
}
```

<p align="center">
	<img src="/img/wait-what-meme.jpg">
</p>

#### Wait...what changed!?

If you look closely, you'll notice that

`compile 'com.android.support:appcompat-v7:23.4.0'` changed to:

`compile "com.android.support:appcompat-v7:$supportLibraryVersion"`

Notice the change from single quotes to double quotes. Also note that the use of `$` here is simply use of [String interpolation](http://docs.groovy-lang.org/latest/html/documentation/index.html#_string_interpolation) in Groovy

Easy peasy!

### What to do for multiple modules?

So, besides you app-module, let's say you also have another `awesome-library` module you have written and is used in this project. This `awesome-library`, uses some dependencies also declared in your app-module.

How do we fix this? You might be tempted to have an `ext` block in both modules. That will work,
but if you need to upgrade the support library version, you will need to modify the version, in both modules.

The fix is simple, we move the `ext` tag to our root project `build.gradle` file.

Our root `build.gradle` file then looks like this:

``` groovy

buildscript {
    ...
}

allprojects {
    ...
}
...

ext {
    // sdk and tools
    minSdkVersion = 14
    targetSdkVersion = 23
    compileSdkVersion = 23
    buildToolsVersion = '23.0.2'

    // dependencies versions
    supportLibraryVersion = '23.4.0'
    playServicesVersion = '9.2.1'
}
```

My module-level `build.gradle` files then look like this:

``` gradle  
apply plugin: 'com.android.application'
android {
    ...
}
...

dependencies {
    // support libraries
    compile "com.android.support:appcompat-v7:$rootProject.supportLibraryVersion"
    compile "com.android.support:design:$rootProject.supportLibraryVersion"
    compile "com.android.support:percent:$rootProject.supportLibraryVersion"
    compile "com.android.support:cardview-v7:$rootProject.supportLibraryVersion"
    compile "com.android.support:gridlayout-v7:$rootProject.supportLibraryVersion"

    //play services
    compile "com.google.android.gms:play-services-location:$rootProject.playServicesVersion"
    compile "com.google.android.gms:play-services-gcm:$rootProject.playServicesVersion"

    // other dependencies
    ...
}
```


### Extra?

I also use this technique to manage `minSdkVersion`, `targetSdkVersion`, `compileSdkVersion` and `buildToolsVersion` in my projects.

Check out this [gist](https://gist.github.com/segunfamisa/b659ebdb04735475b48a7935d646fd03) for a fuller example of how I do this.



If you have any comments/suggestions or corrections, I'd love to hear them. Please do not
hesitate to drop a comment below or [tweet](https://twitter.com/segunfamisa) at me.

Please share if you found this tip useful 🙈😁


Cheers :)
