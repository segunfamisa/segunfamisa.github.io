---
layout: post
title: "Analyzing your Gradle dependencies"
date: 2024-03-14 20:00:00
description: How to analyze your Gradle dependencies
permalink: /posts/analyze-gradle-dependencies
excerpt: How to analyze your Gradle dependencies
comments: false
tags: [gradle, tutorial, tips]
---

> _Featured in [Android Weekly #614](https://androidweekly.net/issues/issue-614/) and [Kotlin Weekly #398](https://mailchi.mp/kotlinweekly/kotlin-weekly-398)_

As Android developers, now and then, we may have to investigate or analyze the Gradle dependencies we are using. Whether we are trying to find out which versions of libraries we are using, or we are trying to find out where one - perhaps unusual dependency is coming from, we may end up needing this knowledge.

A short story. Recently, [leak canary](https://square.github.io/leakcanary/) - which we use to detect memory leaks - was found to be deactivated in our project. Upon investigating, I found that it was [deactivated because a test dependency was accidentally added to the classpath of our debug builds](https://github.com/square/leakcanary/issues/1968#issuecomment-724224577). So, I had to investigate to find out what test dependency is there, and how it got there.

In this post, I will share some tips that can help you analyze our Gradle dependencies and debug them too.

## Analyzing the configurations

First, to analyze the dependencies, one needs to know which kinds of dependencies one is looking for. We can do this by trying to understand _how_ exactly the dependencies are declared - and that determines how they end up in the classpath. In other words, we need to know the configurations.

Configurations are a way for you to tell Gradle how exactly to package these dependencies to achieve the final output. Some dependencies might be used only in compile time, while some are needed both in compile time and runtime. Some might even have special behaviors, or relations to plugins like `kapt` and `ksp`, or only available in certain source sets - like tests.

As described in [Google's guide to declaring dependencies](https://developer.android.com/build/dependencies#dependency_configurations), some of the officially supported configurations include `api`, `implementation`, `compileOnly`, `runtimeOnly` among others.

In version 7.5 and above, Gradle provides a [ResolvableConfigurationsTask](https://docs.gradle.org/current/javadoc/org/gradle/api/tasks/diagnostics/ResolvableConfigurationsReportTask.html) task that reports all the configurations that can be resolved within your project. The task is run as indicated below.

```
./gradlew :app:resolvableConfigurations
```

`app` here can be replaced with whichever Gradle module you are interested in seeing.

The report is printed to the command line, and as a result, I often like to pipe the output of the command to a file, so that I can open and search properly. You can do that by running `./gradlew :app:resolvableConfigurations > conf.txt`.

The report prints all the configurations, including their names, attributes, and other configurations they extend. One of such configurations (`debugCompileClasspath`) is shown below:

```
--------------------------------------------------
Configuration debugCompileClasspath
--------------------------------------------------
Compile classpath for compilation 'debug' (target  (androidJvm)).

Attributes
    - com.android.build.api.attributes.AgpVersionAttr = 7.4.2
    - com.android.build.api.attributes.BuildTypeAttr  = debug
    - org.gradle.jvm.environment                      = android
    - org.gradle.usage                                = java-api
    - org.jetbrains.kotlin.platform.type              = androidJvm
Extended Configurations
    - compileOnly
    - debugCompileOnly
    - debugImplementation
    - implementation

...
```

The compile classpath is typically what you are interested in if you are trying to find out which dependencies are compiled with the app - so you can check the compile classpath for each of your build types and product flavor combinations.

Okay. Now, we have identified the configuration which we want to investigate. Let's proceed to check which dependencies are available in that configuration.

## Analyzing dependencies

To analyze the dependencies, there are two tasks we can use. The `dependency` and the `dependencyInsights` tasks.

The `dependency` task takes a parameter `--configuration` which tells Gradle which configuration's dependencies you are interested in. An example of the run is:

```bash
./gradlew :app:dependencies --configuration debugCompileClasspath
```

The command above prints out all the dependencies applied in the `debugCompileClasspath` configuration - i.e., all the dependencies that are packaged into the debug build. The output of the command looks something like this:

```bash
------------------------------------------------------------
Project ':android:app'
------------------------------------------------------------

debugCompileClasspath - Compile classpath for compilation 'debug' (target  (androidJvm)).
...
+--- org.jetbrains.kotlin:kotlin-stdlib:1.7.20 (*)
+--- org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4 (*)
+--- org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4 (*)
+--- io.arrow-kt:arrow-core:0.8.1
|    +--- org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.3.0 -> 1.7.10 (*)
|    \--- io.arrow-kt:arrow-annotations:0.8.1
|         +--- org.jetbrains.kotlin:kotlin-stdlib:1.3.0 -> 1.7.20 (*)
|         \--- io.kindedj:kindedj:1.1.0
+--- androidx.compose:compose-bom:2022.12.00
...
```

On the other hand, if we already know which dependency we are looking for, we can use the `dependencyInsight` task and specify the `group:name` or a part of the dependency name. For example, to find out information about the arrow-kt dependency above, we can run:

```bash
./gradlew -q app:dependencyInsight --configuration debugCompileClasspath  --dependency arrow-kt
```

## Conclusion

The approaches described above have proven to be immensely helpful in debugging and analyzing dependencies in my projects. I can determine which configurations exist in my project, and with that information, I can explore the dependencies in that configuration.

With these commands, I was able to pinpoint which dependency caused our leak canary to be deactivated and provided a fix.

I imagine that there are additional use cases like investigating a transitive dependency, or in case of version conflicts, finding out how the conflict is resolved and which version supersedes the other, to mention a few.

Thank you for reading. I hope this was helpful or informative in some way.

For more reading about Gradle dependencies, you can have a look at the following resources:

- [https://developer.android.com/build/dependencies](https://developer.android.com/build/dependencies)
- [https://docs.gradle.org/current/userguide/declaring_dependencies.html#sec:what-are-dependency-configurations](https://docs.gradle.org/current/userguide/declaring_dependencies.html#sec:what-are-dependency-configurations)
- [https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html](https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html)
