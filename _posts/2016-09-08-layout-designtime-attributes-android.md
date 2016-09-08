---
layout: post
title: Android studio layout preview with tools attributes
date: 2016-09-08 21:42:45
description: Android Studio tip on using designtime attributes to preview layout designs
permalink: "/posts/android-studio-design-time-attributes"
tags: [android, tip, android studio, android]
excerpt: Android Studio tip on using designtime attributes to preview layout designs
comments: true
twitter_card_image: "/img/android-studio-icon.png"
header_image: /img/android-studio-icon.png
---

This is a short tip for Android Studio users. Many people know this, but I thought to still
share for those that don't know.

As developers, when we're building a UI layout in Android, it's common desire to want to preview what we're designing right?

We usually want to add that sample data, like `android:text="Test Test"` to see how exactly it will look in our layout. Many times, we forget to remove such sample data.
It's even more stressful when you're building a list. You have to run the app to see what your list looks like.

Well, designtime attributes are here to help.

### Designtime attributes? What are they?
Designtime attributes are attributes that are used only in rendering the Android studio layout preview, they have no impact at runtime.
Designtime attributes aren't new in Android studio. They've been around since Android Studio 0.2.11.

Designtime attributes are specified by the use of the `tools` namespace in Android XML layouts.

### Using designtime attributes

#### a. Declare `tools` namespace.
To use the designtime attributes, you need to first declare the `tools` namespace within the root tag of your layout. Your layout will look something like:

```XML
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    ...
    >
    ...
</LinearLayout>
```

All `tools` attributes get stripped out at compile time by [AAPT](http://elinux.org/Android_aapt), and that's how they have no effect at runtime.

#### b. Replace `android` namespace with `tools`
Now that you have declared the namespace, you can replace almost any android xml attribute with tools, for the designtime.

For example, let's say we wanted to test our text wrapping and see how our textview would look with a very long text, we would do something like:

```XML
<TextView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    ...
    tools:text="Test test, let's add some really really really long text"
    />
```

Note the `tools:text` attribute we used instead of the usual `android:text`

### Interesting uses with listviews and recycler views
Now, let's look at further examples of designtime attributes.

#### 1. ListView
You can use designtime attributes to preview what the list will look like if you've designed your list item, using the `listitem` attribute. For example:
```XML
<ListView
    android:id="@+id/list_books"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:listitem="@layout/list_item"
    />
```

#### 2. RecyclerView
Thanks to [Efe](https://twitter.com/efemoney_) for showing me this one.
```XML
<android.support.v7.widget.RecyclerView
    android:id="@+id/recycler_books"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:listitem="@layout/list_item"
    android:scrollbars="vertical"
    tools:scrollbars="none" />
```

### Points to note about designtime attributes
   * It works **ONLY** with Android framework attributes. That is, it doesn't work with custom attributes yet.
   * You can use them together with regular layout android attributes.
   For example
    ```XML
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        ...
        android:text="@string/welcome_text"
        tools:text="Test Test, add some really really really long text"
        />
    ```
   * They only work within Android layout files. You can't use designtime attributes in menus, drawables, etc.

### References and further reading
  * [http://tools.android.com/tips/layout-designtime-attributes](http://tools.android.com/tips/layout-designtime-attributes)
  * [http://tools.android.com/tech-docs/tools-attributes](http://tools.android.com/tech-docs/tools-attributes)


If you have any comments/suggestions or corrections, or you want to share your use of designtime attributes, feel free to drop a comment below or [tweet](https://twitter.com/segunfamisa) at me.

Please share if you found this useful.

Thanks for reading.

Cheers,

Segun.
