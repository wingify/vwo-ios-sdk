# Demo App

## How to run the app
 
 ```
 cd Demo
 pod install
 open VWO Demo.xcworkspace
```

## Setting the API key

### From App

- Open Menu
- Enter API key
- Type/Paste your API key

### Pass argument on launch from Xcode

1. Open Xcode
2. Goto Product -> Scheme -> Edit Scheme
3. Select `Run` in left menu
4. Select `Arguments` Tab
5. Click on '+' button from  `Arguments passed on launch`
6. Put your key in -VWOApiKey <api_key> format. Example: -VWOApiKey 78c9ce301a6d6eg8a8563c94b8c2881e-1234
