---
title: "[Flutter] BLoC——Flutter 中的 MVP"
description: "no description available"
date: 2018-10-31T13:11:09+08:00
draft: false
url: "post/db8412330a33102e25847a876fd66c62"
tags :
  - Flutter
  - BLoC 
---
写过 Android 的应该都会比较熟悉 MVP 模式，在 Flutter 框架下有着相似的 BLoC（Business Logic Component） 模式，不准确地说，BLoC 就是 MVP 在 Flutter 中的变种。

<!--more-->

## StatelessWidget vs StatefulWidget 

在正式开始讲 BLoC 前，先在此回顾下 [Widget](https://flutter.io/tutorials/interactive/#stateful-stateless)。

Widget 在 Flutter 整个绘制过程中，只充当配置的角色，基本不会涉及到的绘制相关的 API，所以在应用运行过程中时刻有大量的 Widget 产生并销毁。但是很多情况下，我们并不想 Widget 的某些状态/数据也一并销毁，比如输入框中已经输入的文本，这时候就有了 Widget 的两个子类——StatelessWidget 和 StatefulWidget。

所以如果我们想要保存一些状态或者实例变量的话，就需要使用 StatefulWidget。

## Stream & Sink

在 [这篇文章](https://yahdude.github.io/Blog/post/c773f50199233831a2379fde98a7b3eb/) 中已经学习了如何通过 `async*` 和 `yield` 来创建一个 Stream，这种方式我们只能对 Stream  下游进行监听，也即上游数据源已经确定了，但是在实际应用中，上游数据应该可以来自程序的不同部分。

Dart 提供了 `StreamController<T>` 这个模板类来帮助开发者创建 Stream 同时向里头添加数据的能力，可以简单的理解成这样：

![](/Users/xavier/tmp/stream_controller.png) 



关于它的一些 API 就不多细说了，官方文档里讲得已经非常清楚。

## BLoC

BLoC 的目的也是将视图和逻辑进行分离，让视图层专注于数据的展示，逻辑层管理状态并处理业务逻辑，这和 MVP 一毛一样。

这里以 Flutter 新建工程为例进行 BLoC 的讲解，先看默认实现：

```dart
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text('$_counter'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

显示当前 FAB 点击次数，FAB 点击后会触发 `_incrementCounter` 进一步调用 `setState` 更新 UI，逻辑比较简单。

再看看使用 BLoC 后的代码实现：

```dart
class _HomePageState extends State<MyHomePage> {
  _HomePageBLoC _bloc;
  _HomePageState() : _bloc = new _HomePageBLoC();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            new StreamBuilder<int>(
              initialData: 0,
              stream: _bloc.count,
              builder: (context, snapshot) {
                return Text('${snapshot.data}');
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bloc.incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _HomePageBLoC {
  int _count = 0;
  StreamController<int> _countController = new StreamController<int>();

  Stream<int> get count => _countController.stream;
  void incrementCounter() {
    _countController.sink.add(++_count);
  }
}
```

这次添加了 `_HomePageBLoC` 作为逻辑层，实现中使用 `StreamController<int>` 来管理点击次数。视图层中，我们需要监听逻辑层中的数据并更新 UI，不过 Flutter 给我们提供了 `StreamBuilder<T>` 来简化操作。

代码已经非常简单了，就不在赘述。不过要注意这里使用了 `StatefulWidget` ， 这是为了在 UI 重建的时候 bloc 实例不会丢失。

## Scoped BLoC

有时候可能会有多个页面共享数据，Flutter 提供 `InheritedWidget ` 帮助我们实现这一目的。具体可以看[这里](https://docs.flutter.io/flutter/widgets/InheritedWidget-class.html) 。



## 关于 Redux 

因为 Flutter 从 React 中借鉴了非常多，所以 React 中 redux 在 Flutter 中也有相应的实现，不过使用上会比 BLoC 繁琐一些，同时相比之下也不够直观。





## Reference 

[build reactive mobile apps in flutter](https://medium.com/flutter-io/build-reactive-mobile-apps-in-flutter-companion-article-13950959e381)

[using a streamcontroller](https://www.dartlang.org/articles/libraries/creating-streams#using-a-streamcontroller)  



