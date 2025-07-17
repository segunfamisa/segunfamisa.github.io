---
layout: post
title: "Making Live Templates in Android Studio"
description: Notes about my favourite Android Studio live template
permalink: /posts/android-studio-live-templates
excerpt: Notes about my favourite Android Studio live template
date: 2025-07-17 07:00:00 +0100
tags: [android, android studio, tooling]
---

_If you are already familiar with live templates, feel free to skip to [the live template for kotlin tests](#live-template-for-kotlin-tests)_

If you use IntelliJ-based IDEs like Android Studio, WebStorm, etc., chances are that you have seen some kinds of “shortcuts” (pictured below) show up when you press some key combinations. These are called [live templates](https://www.jetbrains.com/help/idea/using-live-templates.html). 

<div style="text-align: center;">
  <img src="/images/live-template-example.png" alt="Live Template Example" style="max-width: 100%; height: auto;">
<p style="margin-bottom: 1.5em;"></p>
</div>


For example, if you type `sout` in a Java/Kotlin file, you see a pop-up like the one above. When you press tab, it autocompletes into `System.out.println` (in Java) or `println` in Kotlin. 

Live templates allow you to generate common code constructs by typing keywords that trigger the template. This feature is not new, and I definitely remember seeing it in the [Netbeans IDE](https://netbeans.apache.org/front/main/index.html) when I developed J2ME applications.


If, like me, you write a lot of Android code in Android Studio, you may also know that if you type `comp` in a Kotlin file and press the tab key, a composable function is generated.

I have personally found these templates extremely useful for developing faster, and I use them all the time. I even have a few of my own templates, and one of them is the main reason I am writing this article.

—

## Live Template for Kotlin tests

One of the things I do almost every day when I write code is write tests. If you use Kotlin, you might know that [backticks are allowed in test function names](https://kotlinlang.org/docs/coding-conventions.html#names-for-test-methods).

I like to optimise my workflow, and I realised this was an opportunity to save myself a few keystrokes for every test I write. I ended up writing a live template to automatically create a test function with backticks (does anyone else find the backtick key awkwardly placed on the keyboard?).

To set this up, I follow the instructions on [JetBrains’ website](https://www.jetbrains.com/help/idea/creating-and-editing-live-templates.html). You can do the same:

1.  `CMD` + `,`  to open settings
2. Navigate to `Editor > Live Templates` 
3. Select `Kotlin` group (the templates are usually grouped, but you can also create your own group if you so please)
4. Click on the little `+` button or `CMD` + `N` , and select `1` or `Live Template` 

Now we can begin to set the details for the live template.

The first thing is to set an abbreviation and a description for the template. I used `ktest` for the abbreviation and a description that says *“Creates a Kotlin test function with backticks”.*

Next, I define the applicable context. Since this is a test function, I set it to `Kotlin > Class`. If you want to define a live template applicable to other kinds of files, you can also set that there.

Then the template text:

```
@Test
fun `$NAME$`() {
    $END$
}
```

The `$NAME$` and `$END$` here are variables in the templating system. 

- `$END$` indicates the position of the cursor **after** the template has been executed.
- `$NAME$` is a variable for the function name.

The overall setup looks like this for me:

<div style="text-align: center;">
  <img src="/images/custom-live-template-setup.png" alt="Kotlin Test Live Template Setup" style="max-width: 100%; height: auto;">
</div>

And when I type `ktest` in a test file, this pops up:

<div style="text-align: center;">
  <img src="/images/custom-live-template-usage.png" alt="Kotlin Test Live Template Usage" style="max-width: 100%; height: auto;">
  <p style="margin-bottom: 1.5em;"></p>
</div>


## The templating system

The templating system is more involved than shown here, and the template could be much more complex. In this example, we are not really using the function name for anything else.

Let’s imagine for a moment that we wanted to add a comment with the function name capitalised. To do that, we could introduce a new variable called `$COMMENT$`. Then, we can edit the variable and apply [one of the pre-defined template functions](https://www.jetbrains.com/help/idea/template-variables.html#predefined_functions) to the `NAME` variable.

## What else is this useful for?

Another use-case for live templates is for live coding demos or presentations. If you are doing a live coding demo and expect to create certain scaffolding, you can prepare it as a live template before your presentation.

## What about sharing?

Unfortunately, sharing the template is a bit manual at the moment. JetBrains does allow you to sync templates, but it only syncs across your IDEs. There does not seem to be an immediately obvious way to automatically share them across your team. I think it’s a solvable problem, but I haven’t had time to look into it yet.

You can see more sharing options on [JetBrains website](https://www.jetbrains.com/help/idea/sharing-live-templates.html).

I hope you have found this note helpful. I initially started this as a note to share with my coworkers and friends, but I decided to write it here, in the spirit of wisely spending the [keystrokes I have left](https://keysleft.com/) :D.
