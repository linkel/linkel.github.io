# Fix for Windows 10, Start Menu Opens And Immediately Disappears

## Start Menu Won't Stay Open

Around October I had a bizarre issue where I could no longer use the Start Menu for anything other than searching for an application. I had been using Windows 10 for about a year (I had upgraded in Nov 2020 for the sake of playing Assassin's Creed Valhalla) with no issues. I'd previously been on Windows 7. 

When I opened the Start Menu, whether by hitting the Start Menu key or by clicking it, if I immediately began typing it would successfully search for applications. But if I left it open or tried to click the sleep option, it'd flicker and then disappear. 

I went a week or two hobbled with this (I had to use the power button on my case to sleep or shut off the PC) and then I got annoyed enough to fix it. 

## The Cause: Live Tiles 

In my case it turned out to be due to the "Live Tiles". They're the customizable squares in the Start Menu that are sometimes animated, or show live updates for the weather and other miscellaneous items I've never paid attention to. 

## The Fix

I had to use the "Group Policy Editor" to turn off live tiles, restart, and then I think I may even have manually disabled the live tiles out of caution. 

1. Open the Start menu and very quickly type gpedit.msc and hit enter. If you're not quick, the Start Menu will close. 
2. Alternately, Windows + R will open the Run command, and you can type gpedit.msc in that and hit enter to run it. 
3. Navigate to Local Computer Policy > User Configuration > Administrative Templates > Start Menu and Taskbar > Notifications.
4. Double-click the "Turn off tile notifications entry" on the right and select enabled in the window that opens.
5. Click OK and close the editor.

According to the internet, there's no need to restart for this policy change, but I was not able to open the Start Menu until I had restarted. 

After restarting, I was able to open the Start Menu, and I believe I even right clicked all the tiles and disabled them (or whatever the equivalent of deleting them was in the menu that opened up). 

Since doing the above, my Start Menu has returned to working condition. How bizarre that this would be so glitchy. I wonder if there was an interaction with my previous installation of Windows 7 that caused this? I've been using the same desktop computer, Theseus' ship style, since 2012. Many parts have been replaced over time (motherboard, GPU x2, CPU, PSU x2, RAM) but I've kept all the hard drives I have added over the years. 

So hopefully if you stumble across this with the same issue, this fix works for you. 
