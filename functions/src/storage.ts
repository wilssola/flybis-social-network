const baseUrl: string =
  "https://firebasestorage.googleapis.com/v0/b/flybis.appspot.com/o/";

const storageBucket: string = "flybis.appspot.com";

export function getPathStorageFromUrl(url: String) {
  let path: string = url.replace(baseUrl, "");

  const indexOfEndPath = path.indexOf("?");

  path = path.substring(0, indexOfEndPath);

  path = path.split("%2F").join("/");

  return path; //`${storageBucket}/${path}`;
}

export function getDirectoryStorageFromUrl(url: String) {
  let path: string = url.replace(baseUrl, "");

  const indexOfEndPath = path.indexOf("?");

  path = path.substring(0, indexOfEndPath);

  const splitedPath = path.split("%2F");
  splitedPath[splitedPath.length - 1] = "";
  
  path = splitedPath.join("/");

  return path; //`${storageBucket}/${path}`;
}
