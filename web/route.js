if (
  location.hostname.indexOf("flybis.tecwolf.com.br") === -1 &&
  location.hostname.indexOf("localhost") === -1 &&
  navigator.userAgent.toLowerCase().indexOf("electron") === -1
) {
  location.href = "https://flybis.tecwolf.com.br" + window.location.pathname;
}
