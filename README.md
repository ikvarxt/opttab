# OptTab

OptTab is a small native macOS app switcher prototype.

Hold **Left Option** to show a horizontal bar of Dock apps. While still holding Left Option, press the letter shown on an app to activate it. Release Left Option to close the bar.

Open the menu bar item and choose **Settings...** to change:

- hold key
- app source
- window behavior
- keyboard layout
- letter order
- fixed app keys
- launch at login
- app name visibility
- whether the bar closes immediately after switching

The hold key can be a specific left/right modifier or either side of Option, Command, Control, or Shift.

Fixed app keys reserve specific letters for specific apps. They take priority over the dynamic Dock/running app list.

## Run from source

```sh
swift run
```

The first run needs macOS Accessibility permission because OptTab listens for global keyboard events.

Open **System Settings > Privacy & Security > Accessibility**, enable the app that launched OptTab, then restart OptTab. If you use `swift run`, the permission usually belongs to your terminal app.

## Build an app bundle

```sh
scripts/build.sh
open build/OptTab.app
```

When launched as `build/OptTab.app`, grant Accessibility permission to **OptTab** itself.

Useful build commands:

```sh
scripts/build.sh debug
scripts/build.sh package
scripts/build.sh verify
scripts/build.sh open
```

## Defaults

- Hold key: Left Option
- App source: pinned Dock apps first, then currently running regular apps
- Keyboard layout: QWERTY
- Letter order: home row first, then the rest of the alphabet
- Show app names: off
- Close after switching: off
