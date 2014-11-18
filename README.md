Transmission Interface Binder
=============================

A standalone application to bind Transmission to a device interface. (tun0, ppp0, etc)

This OS X application will allow you to tunnel your Transmission traffic through an interface of your choice. Transmission falls short because it only offers the ability to bind to the IP adress of an interface, these are dynamic, so every time you reconnect to your VPN this IP will be different.

![alt tag](https://raw.githubusercontent.com/joshbernfeld/Transmission-Interface-Binder/dfc76bde8b134dfbdc7c4d28c064711bfd857e5b/Preview/main.png)

**How does this work?**

A device interface of your choice is monitored by the application in the background for changes. If the interface is created, destroyed or altered, its local IP will be retrieved and written into the BindIPV4Address field of the Transmission configuration file. If this happens while Transmission is running, Transmission will be gracefully restarted and will then bind to the newly provided IP address.

**I tunnel all of my traffic through my VPN, why should I use this?**

If your VPN disconnects while Transmission is running, your traffic will revert to your default network.
If you attempt to open Transmission while your VPN is not running, a warning message will apear asking if you are sure you would like to open Transmission.

**What does it look like when I am not connected to my VPN and I try to open Transmission?**

![alt tag](https://raw.githubusercontent.com/joshbernfeld/Transmission-Interface-Binder/master/Preview/alert.png)

**If I disconnect from my VPN while Transmission is open and seeding will traffic revert to my default network?**

**No.** When Transmission first starts it will bind to the IP address of your selected interface. If that IP address and interface disappear, it will stay bound to it but no traffic will pass through. You will see your seeders disconnect and any outgoing connections dropped.


**Why has this feature not been impleneted directly into Transmission?**

The feature is not a particularly easy and straightforward one to implement. Especially considering it needs be done for multiple platforms, some of which may not even support the feature to begin with. Since it is a feature that a small amount of advanced users would use, the amount of code required to implement the feature would not be worth it. Some code patches have been presented which implement the feature, but they are not short. They also need to be recomplied for each version of Transmission, which most people are not capapble of.