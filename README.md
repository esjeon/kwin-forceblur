
Force Blur
==========

A KWin script to force-enable KWin Blur effect on user-specified windows.

![image](image.png)

This is more useful than script-based hacks, because KWin script receives event
notification and window info from KWin. This can also fix tray-based apps,
which loses blur hints when restored from system tray.


How to Use
----------

1. Install the script.

2. Run the following in terminal, to enable script configuration:

	mkdir -p ~/.local/share/kservices5/
	cp ~/.local/share/kwin/scripts/forceblur/metadata.desktop ~/.local/share/kservices5/forceblur.desktop

3. Open `Kwin Scripts` page in `System Settings`.

4. Enable `Force Blur` script by checking the checkbox next to it.

5. Change script settings. Note that the script can only match window class.

6. Click `OK` to enable the script.

7. Whenever the setting is changed, you must disable and re-enable the script.  
   (Uncheck -> `Apply` -> Check -> `Apply`)

