# BM Grenoble

iOS application for the Grenoble Municipal Library ([bibliothèque municipale de Grenoble](https://www.bm-grenoble.fr)), [available on the App Store](https://apps.apple.com/app/grenoble-municipal-library/id1483022528?l=en).

## How it works

The Grenoble Municipal Library doesn’t offer a public API to check your account status and loans. This app uses a hidden web view instead, programmatically signing in with the user credentials, then extracting the relevant data by parsing the HTML pages.

## Features

- List current loans

## Roadmap

- Local notification for reminders
- Store credentials in Keychain
- Items cover image
- Renew loans
- Reservations
- Multiple accounts support

## Experimental features

These features are being implemented, and might be available in beta version, but not on the App Store.

- Subscriber card: in-app barcodes are difficult to scan in libraries
- Search books
- Libraries list with info and map

## Bug report

You can report a bug or a missing feature by opening a [GitHub issue](https://github.com/vtourraine/bm-grenoble-ios/issues).

## Contributions

Contributions are welcome. Please fork this repo, commit your changes, then submit a [pull request](https://github.com/vtourraine/bm-grenoble-ios/pulls).

## Credits

This is an independent project by [Vincent Tourraine](https://www.vtourraine.net), not affiliated with the Grenoble Municipal Library.  

## License

This application is available under the MIT license. See the [LICENSE.txt](./LICENSE.txt) file for more info.
