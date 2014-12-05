ClientError
=========

Log NSError or custom errors to the Parse.com database using the Parse iOS SDK and get error email reports.

Instead of logging unexpected, unknown or unhandled errors to the console where you will never see them once your app is distributed, you can log them to your Parse.com database instead.
Written in Swift.
                   
Additionally, you will find a configurable Parse cloud code job in the `ParseJobs` directory that sends emails reporting the latest ClientErrors to your inbox on a regular basis,
so you can easily keep track of them.

## Installation
Install via cocoapods by adding this to your Podfile:

	pod "ClientError"

## Usage

Swift:

```swift

	// for reporting a NSError:
	ClientError.reportError(error)
	
	// or for reporting a custom error:
	ClientError.reportError("MyErrorDomain", code: 42, userInfo:{"ErrorDescription": "unexpected response"})
```


Objective-C:

```objective-c

	// for reporting a NSError:
	[ClientError reportError:error];
	
	// or for reporting a custom error:
	[CientError reportError:@"MyErrorDomain" code:42 userInfo:@{@"ErrorDescription": @"unexpected response"}];
```

## Setup Parse Job for Email Error Reports

You will need an account at one of these two Email Services: [Mailgun](http://www.mailgun.com) or [Mandrill](http://www.mandrill.com). A free account should be sufficient. After signup, create an API key.

Copy the file ParseJobs/clientErrorMailJob.js to your Parse cloud code folder and include it in your /cloud/main.js like so and deploy:

	require("cloud/clientErrorMailJob.js")
	
In your Parse Account, go to *Jobs* and *Schedule a Job*. Give it a description you like and choose the job named sendClientErrorMail. You will need to configure your job with parameters:

* `providerName`: the email service cloud module you want to use. You can choose between "mailgun" and "mandrill". 
* `credentials`: an array of strings with the required credentials. Mandrill requires just an API key, Mailgun a domin and an API key.
* `parameters`: the parameters to send to the email service except the message text itself. The required parameters depend on the type of email service. Check out the cloud module guide for [Mailgun](https://www.parse.com/docs/cloud_modules_guide#mailgun) and [Mandrill](https://www.parse.com/docs/cloud_modules_guide#mandrill) or look at the Mandrill example below.
* `elapsedHours` (optional): find and send errors that occured during the last x hours, default is one day
* `limit` (optional): reported errors per mail, maximum and default is 1000 
* `omitMailIfNoError` (optional): do not send a mail report if the count of new errors is zero, default is true
* `installationDigits` (optional): anonymize the Parse Installation ID where the error occured for privacy and security reasons to the first 4 digits as default e.g. 'jd7a******'. 0 would be completely hidden ('**********'), 10 would be full length ('jd7a0asOpY').

These are the minimal parameters required for Mandrill as example:

```json

	{
	"providerName": "mandrill",
	"credentials": ["YOUR_MANDRILL_API_KEY"],
	"parameters": {
	  "message": {
	    "subject": "My Projects's Weekly Error Report",
	    "from_email": "myproject@example.com",
	    "from_name": "My Projects's Backend Service",
	    "to": [
	      {
	        "email": "me@example.com",
	        "name": "My Name"
	      }
	    ]
	  },
	  "async": true}
	}
```

The email report itself is a simple, comma-separated, plain text list.