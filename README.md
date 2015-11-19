# VWO

[![CI Status](http://img.shields.io/travis/Swapnil Agarwal/VWO.svg?style=flat)](https://travis-ci.org/Swapnil Agarwal/VWO)
[![Version](https://img.shields.io/cocoapods/v/VWO.svg?style=flat)](http://cocoapods.org/pods/VWO)
[![License](https://img.shields.io/cocoapods/l/VWO.svg?style=flat)](http://cocoapods.org/pods/VWO)
[![Platform](https://img.shields.io/cocoapods/p/VWO.svg?style=flat)](http://cocoapods.org/pods/VWO)

## Installation
VWO is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'VWO'
```

## iOS Version Support

This library supports iOS version 7.0 and above.

## Setting up VWO Account

Sign Up for VWO account at https://vwo.com

## Getting Started Documentation
* [Installation Instructions](https://vwo.com/knowledge/integrating-ios-sdk/)
* [Creating and Running Campaign](https://vwo.com/knowledge/folder-creating-mobile-app-campaigns/)

## Author

Wingify, info@wingify.com

## License

By using this SDK, you agree to abide by the [VWO Terms & Conditions](https://vwo.com/terms-conditions).

## API
**1.) API to fetch settings**

* Type: GET
* URL: https://dacdn.vwo.com/mobile
* Parameters:

>a: account id, account id of your vwo account

>i: app key, generated on vwo.com, when app is added. The key generated is of format, appkey-accountId, only pass in app key.

>dt: device type, example, 
	"iPhone7,1": on iPhone 6 Plus
	"iPhone5,3": on iPhone 5c (model A1456, A1532 | GSM)

>os: operating system of mobile, example
	"iOS 9", "API 21"

>u: UUID of device
	generate and save uuid for the device on first API call. Send the same UUID in subsequent calls.

>r: random number between 0 and 1

>k: current combination of experiments and variation, example
	{103:1,145:3}
	campaign id 103, and variation id 1
	campaign id 145, and variation id 3

>v: library version

* Response:
JSON response, list of all the campaigns running for this app.
* [Sample URL](https://dacdn.vwo.com/mobile?a=10&dt=x86_64&i=cccf243b3e2b18b4bdfbad0a8d2b1f2b&k=%7B%2234%22%3A%222%22%2C%2229%22%3A%221%22%2C%2237%22%3A%223%22%2C%2228%22%3A%221%22%2C%2231%22%3A%221%22%7D&os=9.1&r=0.1312175181839697&u=1F4140267B594340AFEA983544A8E985&v=1.4.4)

**2.) API to record when user becomes part of a campaign**

* Type: GET
* URL: https://dacdn.vwo.com/l.gif
* Parameters:

>experiment_id: campaign id

>account_id: account id, account id of your vwo account

>combination: variation id for the campaign

>u: UUID of device
	generate and save uuid for the device on first API call. Send the same UUID in subsequent calls.

>s: session number, starts from 1. 
	Each time, app is launched, increment session number by 1.

>random: random number between 0 and 1

>ed: extra data, string of extra data,any extra data you wish to record. We recommend sending
>	
 * lt: timestamp when user became part of this campaign
 * i: app key
 * av: app version
 * dt: device type
 * os: operating system version	
 * v: library version
 
>example, {"i":"39c9fe3503ba2887a1584451a0158b3c","lt":1443187441.434723,"av":"1.0","os":"8.2","dt":"x86_64"}

* Response:
1 pixel image


**3.) API to record when a goal is triggered for a campaign**

* Type: GET
* URL: https://dacdn.vwo.com/c.gif
* Parameters:

>experiment_id: campaign id

>account_id: account id, account id of your vwo account
combination: variation id for the campaign

>u: UUID of device
	generate and save uuid for the device on first API call. Send the same UUID in subsequent calls.

>s: session number, starts from 1. 
	Each time, app is launched, increment session number by 1.

>random: random number between 0 and 1

>ed: extra data, string of extra data,any extra data you wish to record. We recommend sending
>	
 * lt: timestamp when user became part of this campaign
 * i: app key
 * av: app version
 * dt: device type
 * os: operating system version
 * v: library version

>goal_id: goal id

>r: revenue/value, if any, for this goal

* Response:
1 pixel image

# Points to consider while using API 

* Trigger l.gif only once per campaign.
* Trigger c.gif only once per goal, even if the goal is triggered multiple times.
* If campaign status is EXCLUDED, do not run campaign on this user. Pass, current-k, as k={campaign-id:0}
* If campaign status is equal to PAUSED, pause this campaign.
* If segment_object is present, handle segmentation conditions. Only if user becomes eligible to become part of this campaign, then only make user part of the campaign.