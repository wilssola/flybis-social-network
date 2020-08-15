require("v8-compile-cache");

const {
  app,
  shell,
  ipcRenderer,
  BrowserWindow,
  Tray,
  Menu,
} = require("electron");

const { setup: setupPushReceiver } = require("electron-push-receiver");

const Store = require("electron-store");
const store = new Store();

const AutoLaunch = require("auto-launch");
const autoLauncher = new AutoLaunch({
  name: "Flybis",
});

var startup = store.get("startup"),
  tray = store.get("tray"),
  splash,
  window,
  icon;

// Checking if autoLaunch is enabled.
autoLauncher.isEnabled().then(function (isEnabled) {
  if (isEnabled) {
    startup = true;
  } else {
    startup = false;
  }
});

if (store.get("first") != true) {
  autoLauncher.enable();
  store.set("tray", true);
  console.log("First Start");
  store.set("first", true);
} else {
  console.log("Not First Start");
}

setTimeout(() => {
  if(store.get("clicked") === true) {
    window.show();
    store.set("clicked", false);
  }
}, 100);

app.setName("Flybis");

// Disable cache.
app.commandLine.appendSwitch("disable-http-cache");

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Algumas APIs podem ser usadas somente depois que este evento ocorre.
app.whenReady().then(createWindow);

// Quit when all windows are closed.
app.on("window-all-closed", () => {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q.
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

function createTray() {
  icon = new Tray("./assets/tray.png");

  icon.setTitle("Flybis");
  icon.setToolTip("Flybis");

  const menuTemplate = [
    {
      label: "Flybis",
      enabled: false,
    },
    {
      label: "System Startup",
      type: "checkbox",
      checked: startup,
      click: () => {
        startup = !startup;

        if (startup) {
          autoLauncher.enable();
        } else {
          autoLauncher.disable();
        }
      },
    },
    {
      label: "Close Tray",
      type: "checkbox",
      checked: tray,
      click: () => {
        tray = !tray;

        store.set("tray", tray);
      },
    },
    {
      label: "Show",
      click: () => {
        console.log("Clicked on Show");
        window.show();
      },
    },
    {
      label: "Help",
      click: () => {
        console.log("Clicked on Help");
        shell.openExternal("https://flybis.tecwolf.com.br/help");
      },
    },
    {
      label: "Quit",
      click: () => {
        console.log("Clicked on Quit");
        app.exit();
      },
    },
  ];

  const menu = Menu.buildFromTemplate(menuTemplate);
  icon.setContextMenu(menu);

  icon.on("double-click", () => {
    window.show();
  });
}

function createWindow() {
  splash = new BrowserWindow({
    frame: false,
    width: 256,
    height: 256,
  });
  splash.setMenuBarVisibility(false);

  // Cria uma janela de navegação.
  window = new BrowserWindow({
    minWidth: 512,
    minHeight: 512,
    width: 1024,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      enableRemoteModule: false,
      nodeIntegrationInWorker: false,
      worldSafeExecuteJavaScript: true,
      devTools: process.env.NODE_ENV === "production" ? false : true,
    },
    show: false,
  });

  window.setMenuBarVisibility(false);

  // Call it before 'did-finish-load' with window a reference to your window.
  setupPushReceiver(window.webContents);

  // Load the app on Web.
  window.loadURL("https://flybis.tecwolf.com.br", {
    extraHeaders:
      "Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-eval'; object-src 'self'",
  });

  window.on("ready-to-show", () => {
    splash.close();
    window.show();

    createTray();
  });

  // Emitted when the window is closed.
  window.on("close", (event) => {
    if (store.get("tray") === true) {
      event.preventDefault();
      window.hide();
    }
  });
}
