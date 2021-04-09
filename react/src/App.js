import React from "react";

import LocalizedStrings from "react-localization";
import MobileStoreButton from "react-mobile-store-button";
//import { Adsense } from "@ctrl/react-adsense";

import {
  BrowserView,
  MobileView,
  isAndroid,
  isMacOs,
  isWindows,
} from "react-device-detect";

import "./utils/firebase.js";

import "./App.css";
import logo from "./flybis-logo-256x68.png";

const desktopOS = isWindows ? "Windows" : isMacOs ? "MacOS" : "Linux";
const desktopUrl = isWindows ? "Windows" : isMacOs ? "MacOS" : "Linux";

const iosUrl = "";
const androidUrl = "";

const strings = new LocalizedStrings({
  en: {
    privacy: "Privacy",
    support: "Support",
    about: "About",
    download: "Download",
    download_system: "Download for " + desktopOS,
    open: "Open Flybis",
    open_browser: "Open the Flybis on Browser",
    slogan: "The New Dynamic Social Network",
    description:
      "A place where your opinion directly influences the relevance and dissemination of all content created by the community.",
    available: "Available on Web, Windows and Android",
  },
  pt: {
    privacy: "Privacidade",
    support: "Suporte",
    about: "Sobre",
    download: "Baixar",
    download_system: "Baixar para " + desktopOS,
    open: "Abrir Flybis",
    open_browser: "Abrir o Flybis no Navegador",
    slogan: "A Nova Rede Social Dinâmica",
    description:
      "Um lugar onde a sua opinião influencia diretamente na relevância e divulgação de todos os conteúdos criados pela comunidade.",
    available: "Disponível para Web, Windows e Android",
  },
  pt_br: {
    privacy: "Privacidade",
    support: "Suporte",
    about: "Sobre",
    download: "Baixar",
    download_system: "Baixar para " + desktopOS,
    open: "Abrir Flybis",
    open_browser: "Abrir o Flybis no Navegador",
    slogan: "A Nova Rede Social Dinâmica",
    description:
      "Um lugar onde a sua opinião influencia diretamente na relevância e divulgação de todos os conteúdos criados pela comunidade.",
    available: "Disponível para Web, Windows e Android",
  },
});

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />

        <ul>
          <li>
            <a
              className="App-link App-header-item"
              href="/download"
              rel="noopener noreferrer"
            >
              {strings.download}
            </a>
          </li>
          <li>
            <a
              className="App-link App-header-item"
              href="/privacy"
              rel="noopener noreferrer"
            >
              {strings.privacy}
            </a>
          </li>
          <li>
            <a
              className="App-link App-header-item"
              href="mailto:flybis@tecwolf.com.br"
              rel="noopener noreferrer"
            >
              {strings.support}
            </a>
          </li>
          <li>
            <a
              className="App-link App-header-item"
              href="/about"
              rel="noopener noreferrer"
            >
              {strings.about}
            </a>
          </li>
        </ul>

        <a
          className="App-button App-header-item"
          href="/app"
          rel="noopener noreferrer"
        >
          {strings.open}
        </a>
      </header>

      <main>
        <div
          style={{
            color: "white",
            backgroundColor: "rgb(244, 67, 54, 1)",
            padding: "175px 0px",
          }}
        >
          <div>
            <h1>Flybis</h1>
            <h2>{strings.slogan}</h2>
            <h3 style={{ fontWeight: "lighter" }}>{strings.description}</h3>
            <h4 style={{ fontWeight: "initial" }}>{strings.available}</h4>
          </div>

          <div
            style={{
              display: "flex",
              flexDirection: "row",
              justifyContent: "center",
            }}
          >
            <BrowserView style={{ padding: 15 }}>
              <a
                className="App-button"
                style={{ padding: "15px" }}
                href="/app"
                rel="noopener noreferrer"
              >
                {strings.open_browser}
              </a>

              <a
                className="App-button"
                style={{ padding: "15px" }}
                href={desktopUrl}
                rel="noopener noreferrer"
              >
                {strings.download_system}
              </a>
            </BrowserView>

            <MobileView style={{ padding: 5, margin: "auto" }}>
              {isAndroid ? (
                <MobileStoreButton
                  store="android"
                  width="256px"
                  height="64px"
                  url={androidUrl}
                  linkProps={{ title: "Android Store" }}
                />
              ) : (
                <MobileStoreButton
                  store="ios"
                  width="256px"
                  height="64px"
                  url={iosUrl}
                  linkProps={{ title: "iOS Store" }}
                />
              )}
            </MobileView>

            {/*<Adsense
              client="ca-pub-7640562161899788"
              slot="7259870550"
            />*/}
          </div>
        </div>
        <div
          style={{
            color: "white",
            backgroundColor: "rgb(76, 175, 80, 1)",
            padding: "20px",
          }}
        ></div>
        <div
          style={{
            color: "white",
            backgroundColor: "rgb(33, 150, 243, 1)",
            padding: "30px",
          }}
        ></div>
        <div
          style={{
            color: "white",
            backgroundColor: "rgb(0, 188, 212, 1)",
            padding: "40px",
          }}
        ></div>
        <div
          style={{
            color: "white",
            backgroundColor: "rgb(233, 30, 99, 1)",
            padding: "50px",
          }}
        ></div>
        <div
          style={{
            color: "white",
            backgroundColor: "rgb(255, 235, 59, 1)",
            padding: "60px",
          }}
        ></div>
      </main>

      <footer className="App-footer"></footer>
    </div>
  );
}

export default App;
