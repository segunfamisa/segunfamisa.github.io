---
layout: post
title: "Selectively running Android UI tests"
date: 2024-12-14 00:00:00
description: Notes about selectively running instrumentation tests on Android
permalink: /posts/selectively-run-android-ui-tests
excerpt: Notes about selectively running instrumentation tests on Android
comments: false
tags: [android, gradle, tutorial, tips]
---

## Intro

> This is really a note for my future self.
>

Recently, I had a situation where I wanted to perform some extra checks after a test has been run. These additional checks are done after each test is run via a Junit rule `SpecialRule` which is applied to a test suite.

For the purpose of illustration, let’s say our `SpecialRule` looks like this:

```kotlin
class SpecialRule : TestRule {

    override fun apply(statement: Statement, desc: Description): Statement {
        return object : Statement() {
            override fun evaluate() {
                try {
                    // Run the test.
                    statement.evaluate()
                } finally {
                    // Perform extra checks after the test.
                    Log.d("SpecialRule", "performing extra checks")
                }
            }
        }
    }
}
```

However, we were concerned about the run duration of the tests being extended significantly by the extra checks, so we wanted a bit more control. That led to some constraints. We wanted to:

1. be able to selectively perform those checks on specific tests
2. perform those checks only under certain conditions.

## Constraint #1 - Selectively perform additional checks on specific tests

The immediate approach that came to mind was to use a custom annotation - `@SpecialTest`, and then somehow find a way to target the tests that are annotated with this.

Luckily, the [`AndroidJunitRunner`](https://developer.android.com/reference/androidx/test/runner/AndroidJUnitRunner#typical-usage) provides various filters to target specific annotations. For example, to run all the tests annotated with `@SpecialTest` , we will use something like:

```bash
adb shell am instrument -w -e annotation com.mypackage.SpecialTest com.android.foo/androidx.test.runner.AndroidJUnitRunner
```

If you use [Flank to run your tests on Firebase Test Lab](https://cloud.google.com/sdk/gcloud/reference/firebase/test/android/run#--test-targets), then you can use:

```bash
--test-targets:
	"annotation com.mypackage.SpecialTest"
```

Now that we can selectively target the tests, we need to extend our test rule to only perform these checks if the test is annotated with `@SpecialTest` annotation. Our `SpecialRule` then becomes something like:

```diff
class SpecialRule : TestRule {

  override fun apply(statement: Statement, desc: Description): Statement {
    return object : Statement() {
      override fun evaluate() {
        try {
          // Run the test.
          statement.evaluate()
        } finally {
          // Perform extra checks after the test.
-          Log.d("SpecialRule", "performing extra checks")
+          if (desc.annotations.any { it is SpecialTest }) {
+ 	        Log.d("SpecialRule", "performing extra checks")
+          }
        }
      }
    }
  }
}
```

So, now we have fulfilled the first constraint. We are now able to selectively perform these extra checks on tests that interest us.

## Constraint #2 - Perform those checks only under certain conditions.

For the second constraints, we want to be able to perform the checks only under certain conditions. We don't want to always run those selected tests.

Let’s say we want to run these checks only on the `main` branch and not on every pull request, or we want to run it only when it’s run in CI, and not locally.

How do we do that? I imagine that there may be multiple ways to solve this second constraint.

The approach I went with was to somehow find a way to pass a “flag” from our build system - into the test rule we have, so that we can use that flag to determine whether to perform the checks or skip them.

As it turns out we can pass arguments to the instrumentation test, using the `-e <key> <value>` [flag](https://developer.android.com/studio/test/command-line#am-instrument-flags) or through the `testInstrumentationRunnerArguments` property in Gradle. We can then retrieve these arguments in the test rule using the [`InstrumentationRegistry.getArguments()`](https://developer.android.com/reference/androidx/test/platform/app/InstrumentationRegistry#getArguments()) API.

Let’s say we want to pass a flag called `extra-checks` , we can do:

```bash
// cli with gradle
./gradlew connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.extra-checks=true
```

or using the Gradle DSL

```kotlin
android {
	//...
	testInstrumentationRunnerArguments["extra-checks"] = "true"
}
```


To retrieve this in our test rule, our test rule becomes:

```diff
class SpecialRule : TestRule {

  override fun apply(statement: Statement, desc: Description): Statement {
    return object : Statement() {
      override fun evaluate() {
        try {
          statement.evaluate()
        } finally {
          val isAnnotated = desc.annotations.any { it is SpecialTest }
+          val arguments = InstrumentationRegistry.getArguments()
+          val hasArgument = arguments.getString("extra-checks") == "true"
-          if (isAnnotated) {
+          if (hasArgument && isAnnotated) {
            Log.d("SpecialRule", "performing extra checks")
          }
        }
      }
    }
  }
}
```

So now, we can selectively decide when to *activate* this special rule and special checks based on an argument that is passed when we run the test, and have solved the second constraint.

Hopefully, some of this has been useful in some way.
