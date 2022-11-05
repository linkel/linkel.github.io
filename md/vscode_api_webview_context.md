# VS Code Extension Development: Webview Context Menu API

I've been working on a Visual Studio Code extension lately and one of the many handy features that Microsoft has provided is [Webviews](https://code.visualstudio.com/api/extension-guides/webview). Via the Webview API, you can show custom HTML, use React to render into the editor, or display anything else that fits in an editor panel's frame.

Amusingly and classically, the feature set is constantly evolving faster than its documentation. This is both delightful and frustrating.

## Customizing Right-Click Context Menu

One quirk of webviews is that the right click context menu by default contains the trifecta Copy, Cut, and Paste, regardless of its usefulness in your webview. I might be showing a table full of cells of historical stock market data and the vanilla right click will show cut and paste--a potentially weird user experience to see on a table one doesn't expect to edit.

Luckily in 2018 a [feature request](https://github.com/microsoft/vscode/issues/54285) came in to allow extensions to contribute to the context menu in a webview.

The 1.70 update of VS Code listed this proposed feature in its [release notes](https://code.visualstudio.com/updates/v1_70#_webview-context-menus). Proposed features aren't able to be published with the extension--they can only be used when distributed as a vsix. This was disappointing since I badly wanted to be able to leverage this feature. 

However, I noticed that contribWebviewContext didn't show up in autocomplete for proposed API features in the package.json. I did some code reading and saw that on September 9th, 2022 this feature was taken off the proposed API list and [finalized into the release](https://github.com/microsoft/vscode/pull/160561/files).

That's awesome! Also a little frustrating that it wasn't announced anywhere in the next release, but Microsoft's VS Code team pumps out so much goodness that it's easy to lose track of all the moving parts.


## How to Use

Into the contributes > menus key of the VS Code extension's package.json, you fill in the new field "webview/context" and specify the command you have defined along with a when clause.

```
"contributes": {
  "commands": [
    {
      "command": "myextension.copyCellContent",
      "title": "Copy Cell Content",
    },
  ],
  "menus": {
    "webview/context": [
      {
        "command": "myextension.copyCellContent",
        "when": "webviewSection == 'stock-table'"
      },
    ]
  },
}
```

I had a hell of a time trying to grab the correct context key for the when clause. For some reason the inspect context keys devtools command that can be brought up via CMD+SHIFT+P did not work when I was clicking on any of my webviews.

Thank goodness the data-vscode-context data attribute worked, at least.

Example of what could be rendered out of my React component:
```
<div class="main">
  isLoading
  ? <LoadingSpinner />
  :
  <div data-vscode-context='{"webviewSection": "stock-table", "preventDefaultContextMenuItems": true}'>
      <MyTable results={result.rows} coolStuff={otherData.coolStuff}/>
  <div/>
</div>
```

By specifying the `webviewSection` field inside of that data attribute, I was able to have the `copyCellContent` command show up in the right click menu, without showing the generic Cut, Copy, Paste commands.

On my table component, I had some logic where the selected cell's values would be saved into the state somewhere and executing the `copyCellContent` command used VS Code's clipboard API like so: `vscode.env.clipboard.writeText(cellValue);`

## Hiding Commands From the Command Palette

Good stuff. For an added bonus, any command listed under the contributes field will show up in the Command Palette (CMD+SHIFT+P or CTRL+SHIFT+P) by default, so if you want to hide the command from showing in the palette, you can add:

```
"menus": {
  "commandPalette": [
    {
      "command": "myextension.copyToClipboard",
      "when": "false"
    }
  ],
```