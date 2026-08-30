---
layout: post
title: "Designing Android's missing WorkManager test rule"
slug: androids-missing-work-manager-test-rule
description: Designing Android's missing WorkManagerTestRule to make testing WorkManager easier
permalink: /posts/androids-missing-work-manager-test-rule
excerpt: Designing Android's missing WorkManagerTestRule to make testing WorkManager easier
date: 2026-08-30 07:00:00 +0100
tags: [android]
---

> TL;DR - create a work manager rule to make your tests easier to write. It's not hard to do, and it pays off.

I have been working quite a bit with WorkManager stuff these days, and while attempting to write tests for them, I realised there were things I was doing repeatedly.

Work Manager provides a helpful testing library - [androidx.work:work-testing](https://maven.google.com/web/index.html?q=work-testing#androidx.work:work-testing:2.11.2) and they have a very nice guide on how to write tests for work manager - both [integration tests, and testing worker implementation details](https://developer.android.com/develop/background-work/background-tasks/testing/persistent/integration-testing)[^1], and despite this, I found myself writing a couple of things over and over again.

This post is somewhere between bringing awareness to testing APIs available for WorkManager, and showcasing a test rule that I think can help lower the barrier to testing.

---

## Before

Say I have a `SyncDispatcher` class that does sync, and sometimes, I want to keep existing work, and other times, I want to replace the existing work.

```kotlin
class SyncDispatcher(val workManager: WorkManager) {
  
  fun sync(params: SyncParams) {
    val existingWorkPolicy = if (params.syncAll) {
			ExistingWorkPolicy.REPLACE
    } else {
      ExistingWorkPolicy.APPEND_OR_REPLACE
    }
    
    val workRequest = OneTimeWorkRequestBuilder<SyncWorker>()
      .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
      .build()
    workManager.beginUniqueWork("sync-work", existingWorkPolicy, workRequest)
    	.enqueue()
  }
}
```

If I wanted to test this behaviour in an "integration-testing" style, I could use the [TestDriver API](https://developer.android.com/reference/androidx/work/testing/TestDriver)[^2] of work manager to instrument the constraints that my work depends on, be it initial delay, network condition, period delay (for perioidic work), stopping the work with a reason, and so on.

```kotlin
// SyncDispatcherTest.kt
@Before {
  val config = Configuration.Builder().setExecutor(SynchronousExecutor()).build()
  WorkManagerTestInitHelper.initializeTestWorkManager(testContext, config)
}

@Test
fun `sync all drops all prior sync requests`() = runTest() {
  // given that we have previous sync work enqueued
  dispatch.sync(syncPartialParams)
  
  // when we receive a refresh all
  dispatch.sync(syncAllParams)
  
  // then when all constraints are met
  val requests = WorkManager.getInstance(context)
  	.getWorkInfosForUniqueWork("sync-work")
  	.get()
  val driver = WorkManagerTestInitHelper.getTestDriver(context)
  requests.forEach { driver?.setAllConstraintsMet(it.id)  }
  
  // then we verify that the syncer recorded only the "sync all" params
  assertEquals(
    listOf(syncAllParams), 
    fakeSyncer.recordedSyncParams,
  )
}
```

By the time I want test various combinations of work state, like failed sync, retries, etc, I will be doing a lot of these checks queries, and driver calls. Then, when I want to do it for another worker, I have to do the same scaffolding - [initialising the work manager test init helper](https://developer.android.com/reference/androidx/work/testing/WorkManagerTestInitHelper), and execute various APIs to enqueue work and query the work state.

Over time, I have found that these operations were finite, in some sence. I typically would do things like: make a certain work run (whether by tag, or unique name, or by id), confirm that a certain work is cancelled, and so on.

So, naturally, I started thinking about how to stop writing all these things over, without creating a `BaseWorkManagerTest`, because [test rules are better for composition, than a base test class](https://ncorti.com/blog/junit-rules)[^3].

I thought about simple top-level functions with the convenience APIs I wanted. That would work, but I would still have to copy-pasta a lot of the work manager test initialisation and test cleanup, and the retrieval API. Furthermore, I did not like that the top-level functions would not be scoped to anything.

I understand that it may be hard to find an API that covers everyone's use-cases, so your mileage may vary, but I think an API like this should exist.

## WorkManagerTestRule[^4]

The rule itself is not a lot, the problems I wanted to solve were:

1. Easy initialisation with the ability to override the configuration during setup.
2. Unified API access to work manager test utilities. I noticed some of my test operations involved using the `TestDriver` to modify the work state, and some involved querying the work manager directly to verify the state. I would love a unified API to mess with work manager in my test environment.

### Work Manager Initialisation in tests

```kotlin
class WorkManagerTestRule(
  private val context: Context = InstrumentationRegistry.getInstrumentation().targetContext
) : ExternalResource() {

  private val executor = SynchronousExecutor()

  /**
   * [Configuration.Builder] for the [WorkManager] used in the test.
   *
   * The default value sets the executor to be the [SynchronousExecutor]. To add more config or
   * change the builder, do so before your test setup returns.
   */
  var configBuilder: Configuration.Builder =
    Configuration.Builder().setExecutor(executor).setTaskExecutor(executor)

  val driver: TestDriver? by lazy {
    WorkManagerTestInitHelper.getTestDriver(context)
  }

  val workManager by lazy {
    WorkManager.getInstance(context)
  }

  override fun before() {
    super.before()
    WorkManagerTestInitHelper.initializeTestWorkManager(context, configBuilder.build())
  }

  override fun after() {
    super.after()
    WorkManagerTestInitHelper.closeWorkDatabase()
  }
}
```

If you're using JUnit 5 already in your project (I'm jealous), then you can convert that into an [extension](https://docs.junit.org/5.14.4/extensions/registering-extensions.html) and applying the corresponding [test lifecycle callbacks](https://docs.junit.org/5.14.4/extensions/test-lifecycle-callbacks.html).

### Work Manager Convenience APIs for tests

To solve the problem of convenience APIs, I created a bunch of helper methods that mirror what I tend to do often.

```kotlin

/**
 * Enqueues a [WorkRequest]. The work request only runs if there are no constraints or all the
 * constraints are met.
 *
 * Shortcut for [WorkManager.enqueue]
 */
fun WorkManagerTestRule.enqueue(request: WorkRequest): Operation {
  return workManager.enqueue(request)
}

/**
 * Enqueues a list of [WorkRequest]s. The work requests only run if there are no constraints or all
 * the constraints are met.
 *
 * Shortcut for [WorkManager.enqueue]
 */
fun WorkManagerTestRule.enqueue(requests: List<WorkRequest>): Operation {
  return workManager.enqueue(requests)
}

/**
 * Enqueues a [WorkRequest], and then meets its constraints to execute it.
 *
 * Shortcut for [WorkManager.enqueue] and [TestDriver.setAllConstraintsMet]
 */
fun WorkManagerTestRule.execute(request: WorkRequest) {
  with(request) {
    workManager.enqueue(this)
    driver?.setAllConstraintsMet(id)
  }
}

/**
 * Enqueues a list of [WorkRequest]s, and then meets all their constraints to execute them.
 *
 * Shortcut for [WorkManager.enqueue] and [TestDriver.setAllConstraintsMet]
 */
fun WorkManagerTestRule.execute(requests: List<WorkRequest>) {
  requests.forEach { request ->
    execute(request)
  }
}

/** Executes all work that match the given [query] by meeting all their constraints to. */
fun WorkManagerTestRule.execute(query: WorkQuery) {
  val infos = workManager.getWorkInfos(query).get()
  infos.forEach { setAllConstraintsMet(it.id) }
}

/**
 * Sets all constraints on the WorkManager work with the given [workSpecId]. Shortcut for
 * [TestDriver.setAllConstraintsMet]
 */
fun WorkManagerTestRule.setAllConstraintsMet(workSpecId: UUID) {
  driver?.setAllConstraintsMet(workSpecId)
}
```

I couldn't possibly figure out whatever everyone would like to do, so I decided to expose the driver, and the work manager as well, so if there's some operation that the rule did not support, you could write your own extension and implement it.

The test rule helps me to hide the complexities involved in the work manager lifecycle - which in itself is complex, and tends to bring the complexity into the test code, and I suspect this is why I haven't seen a lot of these integration tests in the project I'm working on.

## After

With the test rule, the original `SyncDispatcher` scenario then looks like this:

```diff
// SyncDispatcherTest.kt
-@Before {
-  val config = Configuration.Builder().setExecutor(SynchronousExecutor()).build()
-  WorkManagerTestInitHelper.initializeTestWorkManager(testContext, config)
-}
+@get:Rule
+val workManagerTestRule = WorkManagerTestRule(context)

@Test
fun `sync all drops all prior sync requests`() = runTest() {
  // given that we have previous sync work enqueued
  dispatch.sync(syncPartialParams)
  
  // when we receive a refresh all
  dispatch.sync(syncAllParams)
  
  // then when all constraints are met
-  val requests = WorkManager.getInstance(context)
-  	.getWorkInfosForUniqueWork("sync-work")
-  	.get()
-  val driver = WorkManagerTestInitHelper.getTestDriver(context)
-  requests.forEach { driver?.setAllConstraintsMet(it.id)  }
+  val syncWorkQuery = WorkQuery.Builder.fromUniqueWorkNames(listOf("sync-work")).build()
+  workManagerTestRule.execute(syncWorkQuery)

  // then we verify that the syncer recorded only the "sync all" params
  assertEquals(
    listOf(syncAllParams), 
    fakeSyncer.recordedSyncParams,
  )
}
```

By the time you apply this to all the work manager states and behaviour you may be testing, all the other workers, etc, this simple rule starts to pay off in terms of test code size and complexity.

## Footnotes
[^1]: [WorkManager integration test guide](https://developer.android.com/develop/background-work/background-tasks/testing/persistent/integration-testing)
[^2]: [WorkManager TestDriver API](https://developer.android.com/reference/androidx/work/testing/TestDriver) for instrumenting the work manager workers
[^3]: ["Don’t be lazy, use @Rules"](https://ncorti.com/blog/junit-rules)
[^4]: [WorkManagerTestRule](https://gist.github.com/segunfamisa/cbce41d25493afe94fe5bb47bf65c20a) - my take on the missing WorkManager test rule
