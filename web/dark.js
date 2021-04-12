darkMode();
function darkMode() {
  if (
    window.matchMedia("(prefers-color-scheme: dark)").matches &&
    localStorage.getItem("flutter.darkMode") != "false"
  ) {
    document.getElementsByTagName("body")[0].style.backgroundColor = "#303030";
  }
}
