# network_internet_checker

The [connectivity](https://pub.dev/packages/connectivity) package and other similar packages only
provides information if there is a network connection, but not if the network is connected to 
the Internet. That's why the 
[network_internet_c hecker](https://github.com/Ogunleye-Similoluwa/network_internet-checker) package
helps you easily manage widgets dynamically based on the device's internet access.

<br>

![Demo](demo/demo.gif)

<br>

## 🧑‍💻 Getting started

```bash
flutter pub add network_internet_checker
```

## 🛠️ Usage


Simply import `package:network_internet_checker/network_internet_checker.dart'` and simply
pass the `Required Parameters` to the  widget. It takes a some required parameter such as the child wiget , an onPressed function, etc.



<br>

---

<br>

### Exemple

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x9f4376f8),
      ),
      home: Scaffold(
        body: ConnectivityWidget(
          noInternetText: const Text("Check your internet and try again", ),
          addIcon: false,
          loadingColor: Colors.brown,
          textButton: Text("Try Again"),
          onButtonPressed: () {
            print("Check your internet and try again"); },
          child: Center(child: const Text("Working",style: TextStyle(fontSize: 20),)),
        ),
      ),
    );
  }
}
```


## ℹ️ Additional Information
Contribute to this project by making a PR ⬆️ or creating a new issue 🐞 on GitHub.
<br>
Do not hesitate to let a 🌟 on the [repo](https://github.com/Ogunleye-Similoluwa/network_connectivity.git) if you find it useful.

## 👷 Maintainers
Created & maintained with 💖 by [Similoluwa Ogunleye](https://www.linkedin.com/in/ogunleye-similoluwa-7b16a1250/).


## 📄 License

```
MIT License

Copyright (c) 2024 Ogunleye-Similoluwa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



```
