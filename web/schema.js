var structuredData = {
  schema: {
    corporation: {
      "@context": "http://schema.org",
      "@type": "Corporation",
      name: "Flybis",
      url: "https://flybis.net",
      address: "Brazil",
      sameAs: [
        "https://facebook.com/flybisnet",
        "https://instagram.com/flybisnet",
        "https://twitter.com/flybisnet",
      ],
    },
    service: {
      "@context": "http://schema.org/",
      "@type": "Service",
      name: "Flybis",
      serviceOutput: "flybis.net",
      description: "flybis.net",
    },
  },
  init: function () {
    var g = [];
    var sd = structuredData;
    g.push(sd.schema.corporation);
    g.push(sd.schema.service);

    var o = document.createElement("script");
    o.type = "application/ld+json";
    o.innerHTML = JSON.stringify(g);
    var d = document;
    (d.head || d.body).appendChild(o);
  },
};

structuredData.init();
