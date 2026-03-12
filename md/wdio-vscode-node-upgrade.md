---
title: Why VS Code Extension E2E Tests Broke After a Node.js Upgrade
date: 2026-03-11
---

# Why VS Code Extension E2E Tests Broke After a Node.js Upgrade

If you use [wdio-vscode-service](https://www.npmjs.com/package/wdio-vscode-service) to E2E test your VS Code extension and you've recently upgraded to Node 20 or 22, did you hit this error?

```
ERROR @wdio/runner: Error: Failed to create session.  
session not created: Chrome failed to start: exited normally.
  (session not created: DevToolsActivePort file doesn't exist)
  (The process started from chrome location
   .../wdio-vscode-service/dist/chromium/index.js is no longer running,
   so ChromeDriver is assuming that Chrome has crashed.)
```

That is a rather inscrutable error. I started debugging. Seemed like other people had hit this because there were some StackOverflow posts and Github issues on wdio-vscode-extension and webdriverio but no solutions.
Initially I gave up due to other priorities. I was letting the CI/CD system run it for me instead of running locally since it was working there. But that's pretty janky.

## The fix

In `wdio.conf.ts`:

```ts
export const config: Options.Testrunner = {
  // ... config ...

  beforeSession() {
    delete process.env.NODE_OPTIONS;
  },
};
```

This fixed it for me. Why?

## What the error meant

The error message is misleading. "Chrome failed to start". When you use `wdio-vscode-service`, the browser part is a chain of processes:

```
WDIO Worker
  → ChromeDriver
    → fake chrome binary, a Node.js script in wdio-vscode-service
      → VS Code's Electron binary
```

ChromeDriver tells Electron to open a DevTools debugging port. If Electron
crashes before creating that port, ChromeDriver gives the generic
"DevToolsActivePort file doesn't exist" error. 

Running with debug logging (`WDIO_LOG_LEVEL=debug`) shows what's
happening inside Electron.

Something like:

```
[FAKE VSCode Binary] STDERR: Error: Failed to load native binding
    at .../binding.js:333:11

Error: Cannot find module './swc.darwin-universal.node'
Require stack:
    - @swc/core/binding.js
    - ts-node/dist/transpilers/swc.js
    - ts-node/register/index.js
    - internal/preload
```

Electron was trying to load `ts-node/register` as a preload module, which pulls
in `@swc/core`, whose native binary was compiled for system Node (v22) and
is incompatible with Electron's embedded Node runtime (a different app binary interface).

Electron then crashes.

## Why is ts-node loading inside Electron?

It is because of `NODE_OPTIONS`.

When you use `autoCompileOpts` in your WDIO config (which I believe most TypeScript setups
do), WDIO's local runner spawns worker processes with TypeScript support. On
Node 20+, it does this by adding to the `NODE_OPTIONS` environment variable:

```js
// @wdio/local-runner/build/worker.js (simplified)
if (nodeVersion('major') >= 20) {
  runnerEnv.NODE_OPTIONS += ' -r ts-node/register';
}
```

`NODE_OPTIONS` is inherited by every child process. The inheritance chain looks
like:

```
WDIO Worker  (NODE_OPTIONS="-r ts-node/register")  ← set here
  → ChromeDriver                                    ← inherited from here on out
    → fake binary (node script)
      → VS Code Electron
```

On Node 16 or 18 (before 18.19), this code path didn't exist. WDIO only added
the `-r ts-node/register` [flag](https://github.com/webdriverio/webdriverio/pull/11202/changes) as a workaround for
[ts-node#2053](https://github.com/TypeStrong/ts-node/issues/2053), which
affected Node 18.19+ and 20+. My tests worked fine before the Node
upgrade, and this was why...

## Why `delete process.env.NODE_OPTIONS` is safe

The `beforeSession` hook runs inside the WDIO worker process after ts-node has
already been loaded and registered. Deleting `NODE_OPTIONS` at this point
doesn't affect TypeScript compilation in the worker because ts-node is already active.
But it does prevent the env var from propagating to ChromeDriver and to
Electron.

## How to confirm this is your issue

If you're not sure whether this is what you're hitting, here's some diagnostic steps to confirm.

1. **Run with debug logging:**

   ```bash
   WDIO_LOG_LEVEL=debug npx wdio run ./wdio.conf.ts 2>&1 | grep -A5 "FAKE VSCode Binary.*STDERR"
   ```

   If you see `ts-node`, `@swc/core`, or `Failed to load native binding` in the
   output.

2. **Check your Node version:**

   ```bash
   node --version
   ```

   Is it >= 20 and your tests used to work on an older Node?

3. **Check if NODE_OPTIONS is set in the worker:**

   Add this temporarily to your wdio config:

   ```ts
   beforeSession() {
     console.log('NODE_OPTIONS:', process.env.NODE_OPTIONS);
   },
   ```

   If the output includes `-r ts-node/register` then it's the same problem. 

## Alternatives

The `beforeSession` hook is a pretty simple fix, but there are other approaches
depending on your setup:

- **Pre-compile your test files.** Remove `autoCompileOpts` entirely. Compile
  your TypeScript E2E files with `tsc` or `swc` before running WDIO, and point
  `specs` at the compiled `.js` files. This avoids `ts-node` altogether.

- **Use the previous working Node version.** I think a lot of affected people are doing this but then you wallow in unupgradable hell. 

## A lesson

I guess environment variable inheritance across process boundaries causes weird failures.

The coincidental thing was that the CI/CD system I work with was some kind of Linux x64, which did not have this problem that my darwin-arm64 macOS machine did. For whatever reason ts-node registers successfully there.

So for anyone else who was having these "Chrome failed to start" or "DevToolsActivePort" errors in their e2e testing setup, see if it's your `NODE_OPTIONS`.
