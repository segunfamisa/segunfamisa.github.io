---
layout: post
title: Retrofiting on Android with Kotlin
date: 2017-05-21 08:42:45
description: Tutorial on how to use retrofit on Android with Kotlin programming language
permalink: "/posts/using-retrofit-on-android-with-kotlin"
tags: [android, tutorial, kotlin, retrofit]
excerpt: Tutorial on how to use retrofit on Android with Kotlin programming language
comments: true
twitter_small_card_image: /img/kotlin-logo.png
header_image: /img/kotlin-logo.png
---

One of the most exciting announcements at this year's Google I/O was the official support
of Kotlin as a first class language for Android development.

Kotlin is not really a new language, it's > 5 years old, and quite mature. You can check out [https://developer.android.com/kotlin/index.html](https://developer.android.com/kotlin/index.html)
for more information on the new adoption.

I plan to share some "how-tos" around using Kotlin in Android development.

This is going to be a first in the series of said _"how-tos"_.
[Retrofit](http://square.github.io/retrofit/) is a very popular networking library
by the good folks at Square, and it is widely used in the dev community. Even [Google](https://github.com/googlesamples/android-architecture-components/blob/master/GithubBrowserSample/app/build.gradle#L67)
uses it in their code samples.

In this post, I will be talking about how do REST API consumption in your
applications using Retrofit + Kotlin + RxJava. We will be making use of the
[Github API](https://developer.github.com/v3/search/#search-users) to fetch the
list of [Java developers in Lagos, Nigeria.](https://api.github.com/search/users?q=location:Lagos+language:Java&page=1&per_page=20)
This post is going to highlight some features of the programming language and
how we can apply them to something we Android developers do daily - make API calls.

# 0. Set Up
This assumes that you have your development setup ready for Kotlin.
In Android Studio 3.0 (Preview), there is now a native support for Kotlin, without manually installing plugins.
Check out [https://developer.android.com/studio/preview/index.html](https://developer.android.com/studio/preview/index.html) to
install the preview. However, if you don't want to install the new Android Studio Preview (I recommend you sideload it with your stable version),
you can set up your current Android Studio using this [guide](https://segunfamisa.com/posts/setting-up-android-studio-for-kotlin-development).

# 1. Add Dependencies
To use Retrofit, you need to add the dependencies to the app-module `build.gradle` file:

```groovy
dependencies {
    // retrofit
    compile "com.squareup.retrofit2:retrofit:2.3.0"
    compile "com.squareup.retrofit2:adapter-rxjava2:2.3.0"
    compile "com.squareup.retrofit2:converter-gson:2.3.0"

    // rxandroid
    compile "io.reactivex.rxjava2:rxandroid:2.0.1"
}
```
The first dependency in the block above is the retrofit dependency, the second is the RxJava2 adapter,
which will help us make our calls reactive - using RxJava2. The third is the gson converter that will
handle the deserialization and serialization of the request and response bodies from & to JSON format.
The last dependency is RxAndroid which will help us with Android specific bindings for RxJava2.

# 2. Create Data Classes
Typically, the next step is to create the data classes which are POJOs (Plain Old Java Objects)
that will represent the responses of the API calls we're going to make.

With the Github API we're considering in this post, we will have users as entities as well as other metadata
about the search results.

A typical Java class that will hold the User data will look like we have in this Github [gist](https://gist.github.com/segunfamisa/0fe6ef27a929967cbacfdfed6e181fcc).
For convenience of the readers, I won't post the class here, but it is a 154-line Java class, describing the User entity.

Here is one of the wins for Kotlin - it is much less verbose than Java. We can reproduce the same class in a readable format in less than 20 lines.

```kotlin
data class User(
        val login: String,
        val id: Long,
        val url: String,
        val html_url: String,
        val followers_url: String,
        val following_url: String,
        val starred_url: String,
        val gists_url: String,
        val type: String,
        val score: Int
)
```

#### Data Classes in Kotlin
We have this concise version of the User entity with Kotlin, thanks to what is called [**data class**](https://kotlinlang.org/docs/reference/data-classes.html) in Kotlin.
Data classes in Kotlin are classes that are designed specifically for classes that do nothing but hold data.

The Kotlin compiler automatically helps us with implementing `equals()`, `hashCode()` and `toString()` methods
on the class and that makes the code even shorter, because we don't need to do that on our own.

We can override the "default" implementation of any of these methods by defining the method.

A nifty feature is that we can create our search results in one single Kotlin file - say `SearchResponse.kt`.
Our final search response class will contain all the related data classes and look like we have below:

**SearchResponse.kt**

```kotlin
data class User(
        val login: String,
        val id: Long,
        val url: String,
        val html_url: String,
        val followers_url: String,
        val following_url: String,
        val starred_url: String,
        val gists_url: String,
        val type: String,
        val score: Int
)

data class Result (val total_count: Int, val incomplete_results: Boolean, val items: List<User>)
```

# 3. Create the API Service Interface
Next step as we usually do in Java is to create the API interface which we will use to
make requests and get responses via retrofit.

Typically in Java, I like to create a convenience "factory" class that creates
the API service when it is needed and I would do something like this:

**GithubApiService.java**

```java
public interface GithubApiService {

    @GET("search/users")
    Observable<Result> search(@Query("q") String query, @Query("page") int page, @Query("per_page") int perPage);

    /**
     * Factory class for convenient creation of the Api Service interface
     */
    class Factory {

        public static GithubApiService create() {
            Retrofit retrofit = new Retrofit.Builder()
                    .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                    .addConverterFactory(GsonConverterFactory.create())
                    .baseUrl("https://api.github.com/")
                    .build();

            return retrofit.create(GithubApiService.class);
        }
    }
}
```

To use this interface, we then make calls like:

```java
GithubApiService apiService = GithubApiService.Factory.create();
apiService.search(/** search parameters go in here **/);
```

To replicate this kind of behaviour in Kotlin, we would have an equivalent `GithubApiService.kt` Kotlin interface that would look like:

**GithubApiService.kt**

```kotlin
interface GithubApiService {

    @GET("search/users")
    fun search(@Query("q") query: String,
               @Query("page") page: Int,
               @Query("per_page") perPage: Int): Observable<Result>

    /**
     * Companion object to create the GithubApiService
     */
    companion object Factory {
        fun create(): GithubApiService {
            val retrofit = Retrofit.Builder()
                    .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                    .addConverterFactory(GsonConverterFactory.create())
                    .baseUrl("https://api.github.com/")
                    .build()

            return retrofit.create(GithubApiService::class.java);
        }
    }
}
```

Usage of this interface and factory class will look like:

```kotlin
val apiService = GithubApiService.create()
apiService.search(/* search params go in here */)
```

Note that we didn't have to use the "name" of the companion object to reference the method,
we only used the class name as the qualifier.

#### Singletons and Companion Objects in Kotlin
To understand what companion objects in Kotlin is, we must first understand what object declarations are in Kotlin.
An object declaration in Kotlin is the way a singleton is made in Kotlin.

Singletons in Kotlin is as simple as declaring an `object` and qualifying it with a name. For example:

```kotlin

object SearchRepositoryProvider {
    fun provideSearchRepository(): SearchRepository {
        return SearchRepository()
    }
}

```
Usage for the above object declaration is:

```kotlin
val repository = SearchRepositoryProvider.provideSearchRepository();
```
With this, we have been able to create a provider that will provide us with a repository instance (that will help us connect to the Github API via the `GithubApiService`).

The object declaration is lazily initialized when accessed the first time - the same way a Singleton works.

**Companion objects** however, are a type of object declaration that is qualified with the `companion` keyword.
Companion objects can be likened to static methods or fields in Java. In fact, if you are referencing a companion
object from Java, it would appear as a static method or field.

The companion object is what is used in the `GithubApiService.kt` Kotlin version above.

# 4. Create Repository
Since we are trying to abstract our processes as much as possible (while leaving it as simple as possible),
we can create a simple repository that handles calling the `GithubApiService` and builds the query string.

The query string matching our specification for this demo app (to find Java developers in Lagos) using the Github API
is `location:Lagos+language:Java`, so we will create a method in the repository that will allow us build this string while taking the location and language
as parameters.

Our search repository will look like this:

```kotlin
class SearchRepository(val apiService: GithubApiService) {
    fun searchUsers(location: String, language: String): Observable<Result> {
        return apiService.search(query = "location:$location+language:$language")
    }
}
```

#### String Templates in Kotlin
In the block of code above, we have used a feature of Kotlin called **"String templates"** to
build our query string. String templates start with the dollar sign - `$` and the value of the variable following it
is concatenated with the rest of the string. This is a similar feature to [String interpolation](http://docs.groovy-lang.org/latest/html/documentation/#_string_interpolation)
in groovy.

# 5. Make Request and Observe API response using RxJava
Now that we have configured our response classes, our repository interface to help us make the request,
we can now make the request and retrieve the API response using RxJava.
This step is similar to how we would do it in Java. In Kotlin code, it looks like this:

```kotlin
val repository = SearchRepositoryProvider.provideSearchRepository()
repository.searchUsers("Lagos", "Java")
        .observeOn(AndroidSchedulers.mainThread())
        .subscribeOn(Schedulers.io())
        .subscribe ({
            result ->
            Log.d("Result", "There are ${result.items.size} Java developers in Lagos")
        }, { error ->
            error.printStackTrace()
        })
```

With this we have made our request and we can retrieve the response and do whatever we want with it.

# Resources
* [Announcement of official support for Kotlin for Android development by Google](https://developer.android.com/kotlin/index.html)
* [Data classes in Kotlin](https://kotlinlang.org/docs/reference/data-classes.html)
* [Companion Objects in Kotlin](https://kotlinlang.org/docs/reference/object-declarations.html#companion-objects)
* [Lazy initialization of singletons](https://en.wikipedia.org/wiki/Singleton_pattern#Lazy_initialization)
* [String templates in Kotlin](https://kotlinlang.org/docs/reference/basic-syntax.html#using-string-templates)

# Summary
In summary, in this post, we have looked at some cool features/properties of Kotlin language and how
we can apply them in using Retrofit + RxJava for network calls.

These features include:

* Data class
* Object declarations
* Companion objects
* String templates
* Interoperability with Java

For the full project demo used in this tutorial, you can check out the source code here: [https://github.com/segunfamisa/retrofit-kotlin-sample](https://github.com/segunfamisa/retrofit-kotlin-sample)

In the future, I will write about other features of the language and give practical examples of how we can apply them in our day-to-day programming in Android dev.

If you found this post useful, please share. Feel free to discuss or ask questions or make corrections in the comments below.

Thanks for reading.

Cheers,
Segun.
