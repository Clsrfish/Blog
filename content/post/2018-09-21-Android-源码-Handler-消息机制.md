---
title: "[Android 源码] Handler 消息机制"
description: "no description available"
date: 2018-09-21T00:14:57+08:00
draft: true
url: "post/ed6857ccbe7a08537c441cba3360a7fc"
tags : 
    - Android
    - Handler
---

做 Android 开发的都知道的 Android 依靠 Handler + Looper + MessageQueue 来消息机制，而且这个问题在校招面试中也是屡试不爽，大致原理也都能说得八九不离十。在仔细查看源码之后发现 Handler 里面还有一些平常开发中不会考虑到的问题，趁着这几天闲了下来就把这部分的知识简单整理下。

<!--more-->

> 为了简单起见，后文内容基于 Android 4.4 的源码

## Handler 入口
整个消息循环主要通过 Handler 向开发者暴露，暴露的接口可以分为两类：`postXXX` 和 `sendXXX`，这两方法最终目的都是向 `MessaheQueue` 中插入一个 `Message`，所以这里分析 `sendMessage` 这个方法。

```Java
public final boolean sendMessage(Message msg)
{
    return sendMessageDelayed(msg, 0);
}

public final boolean sendMessageDelayed(Message msg, long delayMillis)
{
    return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
}

public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
    MessageQueue queue = mQueue;
    if (queue == null) {
        RuntimeException e = new RuntimeException(this + " sendMessageAtTime() called with no mQueue");
        Log.w("Looper", e.getMessage(), e);
        return false;
    }
    return enqueueMessage(queue, msg, uptimeMillis);
}

private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
    msg.target = this;
    if (mAsynchronous) {
        msg.setAsynchronous(true);
    }
    return queue.enqueueMessage(msg, uptimeMillis);
}
```


`Handler` 最终调用到了 `MessageQueue#enqueueMessage` 方法将 `Message` 入队，整个流程比较简单，再简单说两点：
- `SystemClock#uptimeMillis`，这个方法返回值表示系统开机到现在的毫秒数，不用 `System#currentTimeMills` 是因为这个方法是根据系统时间返回的，所以如果发送一个延迟消息后用户修改的系统时间，就会导致出错
- `mAsynchronous`：

