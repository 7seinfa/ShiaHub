## ShiaHub: Privacy policy

Welcome to the ShiaHub app for Android!

This is an app dedicated to serving the Shia Muslim community.

I hereby state, to the best of my knowledge and belief, that I have not programmed this app to collect any personally identifiable information. All data (app preferences (like theme, etc.) and alarms) created by the you (the user) is stored on your device only, and can be simply erased by clearing the app's data or uninstalling it.

### Explanation of permissions requested in the app

The list of permissions required by the app can be found in the `AndroidManifest.xml` file:

https://github.com/7seinfa/ShiaHub-2/blob/main/android/app/src/main/AndroidManifest.xml#L57-L60

<br/>

| Permission | Why it is required |
| :---: | --- |
| `android.permission.RECEIVE_BOOT_COMPLETED` | This is required so that the app may run on start up to set alarms. |
| `android.permission.ACCESS_FINE_LOCATION` | This is required to pull location to calculate prayer times. |
| `android.permission.INTERNET` | This is required to connect to internet to load audio files. |
| `android.permission.USE_EXACT_ALARM` and `android.permission.SCHEDULE_EXACT_ALARM` | This is required to schedule prayer alarms for their exact times. |
 <hr style="border:1px solid gray">

If you find any security vulnerability that has been inadvertently caused by me, or have any question regarding how the app protectes your privacy, please send me an email or post a discussion on GitHub, and I will surely try to fix it/help you.

Yours sincerely,  
Hussein Abdallah.  
7seinfa@gmail.com
