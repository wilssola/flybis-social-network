function loadJS(src, async) {
  let script = document.createElement("script");
  script.async = async;
  script.src = src;
  script.type = "text/javascript";
  //script.integrity = integrity;

  let s0 = document.getElementsByTagName("script")[0];
  s0.parentNode.insertBefore(script, s0);
}

fetch("sri.json")
  .then((response) => response.json())
  .then((json) => {
    console.log(json.sri.find(element => element.file == "dark.js"));

    loadJS("./dark.js", false);
    loadJS("./firebase.js", false);

    window.onload = function () {
      loadJS("./flybis.js", true);
      loadJS("./main.dart.js", true);
      loadJS("./worker.js", true);
    };
  });
