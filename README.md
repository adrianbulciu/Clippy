# Clippy

### Video Demo:  <URL HERE>

### Description:
Meet Clippy, an app made to quickly access clipboard contents, and paste them to the current selected location. 

This is inspired by the clipboard quick access window available on Microsoft Windows.

There are some similar applications already available on the internet, but I wanted to make one myself, for curiosity sake and also security reasons, given the fact that we are dealing with clipboard data.

Made possible with the help of Paul Hudson (@twostraws) [tutorials](https://www.hackingwithswift.com/)/[book on SwiftUI on macOS](https://www.hackingwithswift.com/books/macos-swiftui), Google and AI chats.

> [!IMPORTANT]
> ## Requirements
> This has been developed on MacOS 26.0 so please make sure you have at least that version.

### Installation:
1. Download the app file from the distribution folder.
2. Move the app file to the applications folder.
3. Done, launch the app.

https://github.com/user-attachments/assets/69fe2c28-3fcc-42ed-9cdc-754c3a6e333d

### Setup:
This application best functions with a keyboard shortcut set. 
Also there are accessibility permissions that must be given for the app to be able to paste the selected clipboard text to the destination.

1. This app is a menu bar app, so click on the app icon (a clip with sunglasses) at top of the screen.
2. Go to settings.
3. Set a preferred keyboard shortcut.
4. Allow accessibility permissions to Clippy.
5. That's it.

<img width="396" height="313" alt="Screenshot 2025-12-30 at 17 45 22" src="https://github.com/user-attachments/assets/319a1b8f-55dc-4a1f-9d31-c1bf4c259c7e" />

### How to use:
The shortcut you have set will open the clips window. 

This window will have a list of clipboard items and a search input that will be focused by default. 

You can navigate the list items using up and down arrow keys and pressing enter will paste the selected clip to the current destination available.
Losing focus, pressing 'Esc' or using the same shortcut keybind when the clips window is active will close the window.

### Features that didn't make it in time
Here's a list of all the things that I am thinking on adding to the app or that were planned and did not make it in yet:
- User defined keybinds for navigating the list
- A list of apps that should be excluded when reading clipboard
- Marking favourites in the clips list so they persist when clearing the list, and can be filtered accordingly
- The ability to manually select a clip from the list to be added as the active clipboard item, useful for when pasting automatically might not be wanted
- Editing clips?
- Larger preview when on each clip

## Project files documentation

### 1. ClippyApp.swift

Here is the entrypoint of the app, where the Scene and all its windows are defined and where we also initialize the other files. 

This application consists of 3 SwiftUI windows: a menu bar, the clips window and the settings window.

In this file we also have to setup the callback for the keyboard shortcut that the user sets.
I have come to the solution of using an onChange listener on any window for the initial state of the application and set the callback to either open the window for clips if not already opened or close it otherwise.

As for the clips window, it has a background modifier that positions the window on the bottom center part of the screen. This is done with the help of a WindowAccessor.

### 2. WindowAccessor.swift

This is a helper 'bridge' in order to access the underlying NSWindow where the SwiftUI view is hosted.

In can be used on a SwiftUI view with a callback that will be run on the underlying window for the NSView.

### 3. WindowStore.swift

A file that stores a reference to the clips window globally. Very usefull because it can be accessed anywhere in the app.

### 4. ClipboardViewModel.swift

Here is defined our clipboard data in the appstorage with get/set accessors and the functionality to observe the clipboard.

I have chose to use AppStorge for simplicity, but the downside is that it only supports strings being passed in. So in order to get an array of strings in there I have used a Data value type that is encoded to JSON.

The main part of the logic is in the init() method, where a timer is set to check the clipboard every second for new values, so if a new entry is present this app will capture it.

The current approach does not take into account the future development for user settings to exclude certain apps from being captured.

### 5. AppFocusObserver.swift

Responsible to hide the application clips window when the app loses focus. This is done via the Notification Center with an observer for didResignActiveNotification notification, which is triggered when the app gives its active status to another app.

### 6. AppState.swift

Here is registered the callback for when the keybind shortcut is used. I am using an external package called KeyboardShortcuts which takes care of the most hard parts.

In the ClippyApp file AppState is initialized without a callback. Afterwards, during the state onChange listener, the callback is set.

This is done on purpose, because the window enviorment object is not initialized at the time AppState is initialized, so the callback can't be properly set right at the launch..

### 7. PermissionManager.swift

This file has logic that checks if the permissions for accessibility have been grated and a method that opens the system settings to grant them.

### 8. KeyboardShortucts_Clips.swift

An extension to the KeyboardShortcuts package where the keybind shortcut name is registered in the package.

---
<br>

_That's the end of the backbone files and now we get into the view files._

<br>

---

<br>

### 9. MenuBarView.swift

This is a basic menu for the app which will be visible in the app bar at the top of the screen. It allows the user to reach the settings window, clear/quit the app or manually open the clips window.

Initially I opted to make this be an actual window that would also show a part of the clips and have the settings/quit/clear buttons at the bottom, but in the end I have decided that it's not worth to duplicate the code + extra work just for some fancy part that might not be useful at all.

### 10. SettingsView.swift

Here we have some UI to allow the user to change some settings of the app, no too many, just the amount of clips to have in history and the shortcut keybind to open the clips window. The clip history limit defaults to 50.

There is also a link to give accessibility permissions to the app, which will turn into an labeled content when permissions are granted.

### 11. ClipView.swift

Here we have extracted the view of a singular clip that will be used for each clip when listing them. It's usefull to separate logic, in this case it's easier to handle the hover state of each clip when separated (in my opinion).

### 12. ContentView.swift (the default name got away)

This is the view that displays the clips list. It also handles the interaction with the list and list items.

As I mentioned in the how to use instructions, the user can interact with the list with arrow keys, also with the mouse by hovering over list items. 

The list has a listener for a tap gesture (that works for clicks on macOS) which triggers the paste logic. The same logic is listened for when the enter key is pressed.

Other listeners are present for different actions, for example 'esc' closes the window or 'cmd f' focuses the search input.

The clips listed are actually obtained via a computed propery that filters them if the search text is not empty, this is how searching is implemented.

- Paste Logic:
    - This requires accessibility permissions.
    - It sets the active clipboard item equal to what is selected from the list, then if permissions have been granted, it queues the code that emultates pressing "cmd v", otherwise an it shows an alert to grant permissions to do this.

Unfortunately this action cannot be done without permissions, there is no workaround this.





