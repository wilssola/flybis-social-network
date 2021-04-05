require("v8-compile-cache");

const path = require("path");

const {
  app,
  shell,
  ipcMain,
  ipcRenderer,
  nativeImage,
  BrowserWindow,
  Tray,
  Menu,
} = require("electron");

const { autoUpdater } = require("electron-updater");

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
  if (store.get("clicked") === true) {
    window.show();
    store.set("clicked", false);
  }
}, 100);

// Make singleton instance.
app.requestSingleInstanceLock();
app.on('second-instance', (event, argv, cwd) => {
  console.log(event, argv, cwd);
  app.quit();
});

// Set name.
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
  icon = new Tray(nativeImage.createFromPath(path.join(__dirname, "assets", "icons", "flybis_icon_tray.png")));

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
        shell.openExternal("https://flybis.net/help");
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
  const icon = nativeImage.createFromPath(path.join(__dirname, "assets", "icons", "flybis_icon.png"));

  app.setAppUserModelId("com.tecwolf.flybis");

  splash = new BrowserWindow({
    frame: false,
    width: 256,
    height: 256,
    icon: icon,
  });

  splash.setMenuBarVisibility(false);

  splash.loadFile(path.join(__dirname, "splash.html"));

  splash.once("ready-to-show", () => {
    autoUpdater.checkForUpdatesAndNotify();
  });
  autoUpdater.on("update-available", () => {
    splash.webContents.send("update_available");
  });
  autoUpdater.on("update-downloaded", () => {
    splash.webContents.send("update_downloaded");
    autoUpdater.quitAndInstall();
  });

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
      contextIsolation: false,
      devTools: true,
    },
    show: false,
    icon: icon,
  });

  window.setMenuBarVisibility(false);

  // Call it before 'did-finish-load' with window a reference to your window.
  setupPushReceiver(window.webContents);

  // Load the app on Web.
  //window.loadURL("https://flybis.web.app/app", {
    //extraHeaders: "Content-Security-Policy: default-src 'self'",
  //});

  window.loadFile(path.join(__dirname, "index.html"), {
    extraHeaders: "Content-Security-Policy: default-src 'self'",
  });

  window.on("ready-to-show", () => {
    splash.close();
    window.show();

    createTray();
  });

  ipcMain.on("notification_clicked", () => {
    window.show();
  });

  // Emitted when the window is closed.
  window.on("close", (event) => {
    if (store.get("tray") === true) {
      event.preventDefault();
      window.hide();
    }
  });
}
