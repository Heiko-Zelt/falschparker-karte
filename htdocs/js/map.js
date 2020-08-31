// global variables:
var falschparkerLayer = 0;
var boundaryLayer;
var markersLayerGroup;
var mymap = 0;
var chargeTypes = {};
var icons = new Array();
var showCounter = true;

function formatNumber(num) {
  return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.")
}

function roundCoordinate(num) {
  return Math.round(num * 100000) / 100000;
}

function debugTime() {
  var now = new Date();
  return ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2) + ":" + ("0" + now.getSeconds()).slice(-2) + " ";
}

// Immer wenn sich Header oder Footer aendert, dann Layout anpassen
function resizeMap() {
  console.log(debugTime() + 'resizeMap()');
  console.log('window: ' + $(window).height() + ', header: ' + $('header').height() + ', footer: ' + $('footer').height());
  var mapHeight = $(window).height() - $('header').height() - $('footer').height();
  $('#mapid').height(mapHeight);	
  //setTimeout(function(){mymap.invalidateSize()}, 400);
  mymap.invalidateSize();
}

function transparenzAendern() {
  var v = document.getElementById("transparenz").value;
  var i = parseInt(v);
  var o = (100 - i) / 100;
  falschparkerLayer.setOpacity(o);
  var a = document.getElementById("transparenzAnzeige")
  $('#transparenzAnzeige').html(v + ' %');
}

var noDetailText = '<div>&#x1f6c8; <span style="font-style: italic;">Klicken Sie auf die Karte für Detail-Infos!</span> &#x1f6c8;</div>';

function jump(lng, lat, zoomLevel) {
  console.log(debugTime() + 'jump()');
  mymap.setView(new L.LatLng(lat, lng), zoomLevel);
  // L.map('mapid').setView([y, x], z);
  $('footer').html(noDetailText);
}

function jumpOrCreate(lng, lat, zoomLevel) {
  if($('div#mapid').length) {
    jump(lng, lat, zoomLevel);
  } else {
    var params = new URLSearchParams();
    params.append('x', lng);
    params.append('y', lat);
    params.append('z', zoomLevel);
    createMap(params);
  }
  //resizeMap(); 
}

function jumpBoundary(osmId) {
  console.log(debugTime() + 'jump to boundary ' + parseInt(osmId));
  var url = "/gis/boundary"
  $.getJSON(url + '?osmid=' + osmId, function (jsonResponseBody) {
    if(jsonResponseBody) {
      console.log(debugTime() + "JSON WS /gis/boundary successful: " + jsonResponseBody.ok);
      if(jsonResponseBody.ok) {
        boundaryLayer.clearLayers();
        boundaryLayer.addData(jsonResponseBody.way);
        mymap.fitBounds(boundaryLayer.getBounds());
      } else {
        console.log(jsonResponseBody.errorMessage);
      }
    } else {
      console.log("Couldn't download JSON-data");
    }
  });
  updateCoordinatesOsmid(osmId);
}

// on zoom/move end:
function updateCoordinates() {
  console.log(debugTime() + 'updateCoordinates');
  var bou = mymap.getBounds();
  console.log('Kartenausschnitt: W ' + bou.getWest() + ', E ' + bou.getEast() + ', S ' + bou.getSouth() + ', N ' + bou.getNorth());
  var qryStr = '?e=' + bou.getEast() + '&w=' + bou.getWest() + '&s=' + bou.getSouth() + '&n=' + bou.getNorth();
  $.getJSON('/gis/notices' + qryStr, function (jsonResponseBody) {
    if(jsonResponseBody) {
      console.log(debugTime() + "JSON WS /gis/notices successful: " + jsonResponseBody.ok);
      if(jsonResponseBody.ok) {
	if(showCounter) {
	  console.log(debugTime() + 'counter html');
	  var h = '<div class="tooltip">&Sigma;: ';
          h += formatNumber(jsonResponseBody.count);
          h += '<span class="tooltiptext">Anzahl Falschparker-Meldungen im Kartenausschnitt</span></div>'
          $('footer').html(h);
	}

        markersLayerGroup.clearLayers();
	console.log("???");
	if(jsonResponseBody.notices) {
	  console.log("!!!");
	  //now = new Date(jsonResponseBody.now);
	  //console.log("now as Date: " + now);
          console.log("length: " + jsonResponseBody.notices.length);
	  jsonResponseBody.notices.forEach(function (n, i) {
	    //console.log("notice: charge_id: " + n.charge_id + ", x: " + n.x + ", date: " + n.date);
            var chargeType = chargeTypes[n.charge_id];
	    //console.log("charge: " + chargeType.name);
            var ico = icons[chargeType.pin_id];
	    //console.log("icon: " + ico);
            var d = new Date(n.date);
            var datStr = ("0" + d.getDate()).slice(-2) + "." + ("0"+(d.getMonth()+1)).slice(-2) + "." +
              d.getFullYear() + ", " + ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2) + " Uhr";
	    switch(n.src) {
              case '1':
	        var s = '<a href="https://www.wegeheld.org/" target="_blank">Wegeheld</a>';
		break;
              case '2':
	        var s = '<a href="https://www.weg-li.de/" target="_blank">weg-li</a>';
                break;
              default:
                console.log("ERROR notice with unknown src");
	        var s = '?'
	    }
            var txt = chargeType.name + '<br>' + datStr + "<br>Quelle: " + s;
            //age = (now.getTime() - d.getTime()) / (24 * 60 * 60 * 1000);
	    //console.log("age: " + age);
            //opacity = 1 - (age / (365 * 3));
            //console.log("marker: y=" + n.y + " x=" + n.x + " chargeId=" + n.charge_id + " pin=" + chargeType.pin_id + " txt=" + txt)
            //L.marker([n.y, n.x], {icon: ico}).bindPopup(txt).setZIndexOffset(i).addTo(markersLayerGroup);
            var markerOptions = {
              icon: ico,
              /* einfacher Workaround: i mal 16, damit suedliche Marker nicht vor noerdlicheren angezeigt werden */
              zIndexOffset: i * 16
            };
            L.marker([n.y, n.x], markerOptions).bindPopup(txt).addTo(markersLayerGroup);
	  });
	}
      } else {
	console.log(jsonResponseBody.errorMessage);
      }
    } else {
      console.log("ERROR Couldn't download JSON-data");
    }
  });

  var c = mymap.getCenter();
  var x = roundCoordinate(c.lng);
  var y = roundCoordinate(c.lat);
  var z = mymap.getZoom();
  var queryStr = '?x=' + x + '&y=' + y + '&z=' + z;
  //var linkText = 'x: ' + x + ', y: ' + y + ', z: ' + z;
  var queryStrEscaped = queryStr.replace(/&/g, '%26');
  var hyperLink = window.location.href.split('?')[0] + queryStr;
  var mailHyperLink = window.location.href.split('?')[0] + queryStrEscaped;
  $('#shareLink').attr('href', queryStr);
  $('#shareLink').html(hyperLink);
  $('#shareMail').attr('href', 'mailto:?subject=Falschparker-Karte&body=' + mailHyperLink);
  console.log(debugTime() + 'coordinates updated');
}

function updateCoordinatesOsmid(osmId) {
  console.log(debugTime() + 'updateCoordinatesOsmid');
  var queryStr = '?osmid=' + osmId;
  var linkText = 'OSM ID: ' + osmId;
  var queryStrEscaped = queryStr.replace(/&/g, '%26');
  var hyperLink = window.location.href.split('?')[0] + queryStrEscaped
  $('#shareLink').attr('href', queryStr);
  $('#shareLink').html(linkText);
  $('#shareMail').attr('href', 'mailto:?subject=Falschparker-Karte&body=' + hyperLink);
}


// Query-String-Parameters?
function createMap(urlParams) {
  console.log(debugTime() + 'createMap()');

  $('#homeIcon').hide();
  $('#layersIcon').show();
  $('#shareIcon').show();
	
  var h = '<div id="mapid">loading...</div>';
  h += '<footer>' + noDetailText + '</footer>'
  $('#main').html(h);

  mymap = L.map('mapid');
  if(urlParams.has('x') && urlParams.has('y') && urlParams.has('z')) {
    console.log(urlParams.get('x'));
    var x = parseFloat(urlParams.get('x'));
    var y = parseFloat(urlParams.get('y'));
    var z = parseInt(urlParams.get('z'));
    jump(x, y, z);
  } else if(urlParams.has('osmid')) {
    var osmid = parseInt(urlParams.get('osmid'));
    jumpBoundary(osmid);
  } else {
    jump(9.6, 51.30, 5);
  }

  // sehr schoen
  var openSteetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?{foo}', {
    foo: 'bar',
    attribution: '&copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    minZoom: 3,
    maxZoom: 19
  });
  openSteetMap.addTo(mymap);

  falschparkerLayer = L.tileLayer('/falschparker_tiles/{z}/{x}/{y}.png', {
    minZoom: 3,
    maxZoom: 19,
    opacity: 0.5,
    transparency: 'true'
  });
  falschparkerLayer.addTo(mymap);

  boundaryLayer = L.geoJSON(null, {
    color: 'black',
    //fillColor: 'white',
    fillOpacity: 0,
    weight: 2
  });
  boundaryLayer.addTo(mymap);

  markersLayerGroup = L.layerGroup();
  markersLayerGroup.addTo(mymap);
	
  /*
  mymap.on('zoomend', function(e) {
    console.log(debugTime() + 'on zoom end');
    updateCoordinates();
  });
  */
  mymap.on('moveend', function(e) {
    console.log(debugTime() + 'on move end');
    updateCoordinates();
  });

  // Klick auf Karte, also Detail-Tabelle anzeigen
  mymap.on('click', function(e) {
    var lat = e.latlng.lat
    var lng = e.latlng.lng
    console.log("clicked on lat:" + lat + ", lng:" + lng);
    var url = "/gis/info"
    $.getJSON(url + '?lat=' + lat + '&lng=' + lng, function (jsonResponseBody) {
      if(jsonResponseBody) {
        console.log(debugTime() + "JSON WS /gis/info successful: " + jsonResponseBody.ok);
        if(jsonResponseBody.ok) {
          if(jsonResponseBody.boundaries.length == 0) {
            var h = "Bitte klicken Sie innerhalb Deutschlands! Außerhalb liegen keine Daten vor."
          } else {
            var h = '<table style="display: inline;">';
            h += '<tr><th>Verwaltungs-Einheit</th><th>Einwohner</th><th>Falschparker-Meldungen</th></tr>';
            jsonResponseBody.boundaries.forEach( function(item, index) {
              h += '<tr>'
              h += '<td><a onclick="jumpBoundary(' + item.osm_id + ');">' + item.name + '</a></td>';
              h += '<td class="number">' + formatNumber(item.ewz) + '</td>';
              h += '<td class="number">' + formatNumber(item.taten) + '</td>';
            });
            h += '</table>';
            // Es gibt andere Kreuzchen in Unicode, aber das Multiplikations-Zeichen ist am besten kompatibel.
            h += '<a id="detailsCancel" style="display: inline;">&#x00D7;</a>';
          }
        } else {
          console.log(jsonResonseBody.errorMessage);
        }
        //console.log(h);
        $('footer').html(h);
        $('#detailsCancel').click(function() {
          $('footer').html('<div>closed</div>');
          showCounter = true;
          resizeMap();
        });
        showCounter = false;
        resizeMap();
      } else {
        console.log("ERROR Couldn't download JSON-data");
      }
    });
  });
}

function init() {
  // Marker-Icons nur einmal laden
  for(var i = 0; i <= 31; i++) {
    icons[i] = L.icon({
      iconUrl: 'pins/' + i.toString() + '.png',
      iconSize: [29, 33],
      iconAnchor: [11, 33]
    });
  }
  // Katalogdaten nur einmal laden
  $.getJSON('/gis/charge_types', function(jsonResponseBody) {
    if(jsonResponseBody) {
      // Array in Dictionary umwandeln
      for(var c of jsonResponseBody.chargeTypes) {
        chargeTypes[c.id] = {
          pin_id: c.pin_id,
          name: c.name
        }
      }
    }
  });
}

function initHotspots() {
  $('#bundeslaenderLink').click(function() {
    console.log(debugTime() + 'bundeslaenderLink klick');
    createBundeslaender();
  });
  $('#regierungsbezirkeLink').click(function() {
    console.log(debugTime() + 'regierungsbezirkeLink klick');
    createRegierungsbezirke();
  });
  $('#grossstaedteLink').click(function() {
    console.log(debugTime() + 'grossstaedteLink klick');
    createMetropolises();
  });
  $('#mittlereGemeindenLink').click(function() {
    console.log(debugTime() + 'mittlereGemeindenLink klick');
    createMittlereGemeinden();
  });

  var targets = [
    {name: "Berlin"          , zooom: 10, lat: 52.50858, lng: 13.38581 }, // 1351
    {name: "Darmstadt"       , zooom: 12, lat: 49.87181, lng:  8.65070 }, // 2792
    {name: "D&uuml;sseldorf" , zooom: 11, lat: 51.23858, lng:  6.81433 }, // 1778
    {name: "Ehingen"         , zooom: 13, lat: 48.28850, lng:  9.71234 }, // 2271 
    {name: "Essen"           , zooom: 11, lat: 51.43726, lng:  7.01168 }, // 1697
    {name: "Frankfurt"       , zooom: 12, lat: 50.12913, lng:  8.64315 }, // 1642
    {name: "Gro&szlig;-Gerau", zooom: 12, lat: 49.90658, lng:  8.48333 }, // 1642
    {name: "Hamburg"         , zooom: 10, lat: 53.55488, lng:  9.99343 }, // 2297
    {name: "Kiel"            , zooom: 11, lat: 54.34190, lng: 10.12577 }, // 1697
    {name: "K&ouml;ln"       , zooom: 11, lat: 50.93630, lng:  6.96258 }, // 2208
    {name: "M&ouml;nchengladbach", zooom:  11, lat: 51.16691, lng: 6.41387 }, // 4384
    {name: "M&uuml;nchen"    , zooom: 11, lat: 48.13762, lng: 11.57135 }, //  445
    {name: "<nobr>Rhein-Main</nobr>" , zooom: 10, lat: 50.00497, lng:  8.37982 },
    {name: "<nobr>Ruhr-Gebiet</nobr>", zooom:  9, lat: 51.30978, lng:  6.92413 },
    {name: "Ulm"             , zooom: 12, lat: 48.38977, lng:  9.97919 }, // 2237
    {name: "Wiesbaden"       , zooom: 11, lat: 50.07515, lng:  8.23974 }  // 1520
  ];
  var h = "";
  targets.forEach( function(item) {
    if(h != "") {
      h += ' ';
    }
    h += '<a onclick="jumpOrCreate(' + item.lng + ', ' + item.lat + ', ' + item.zooom + ');">' + item.name + '</a>'
  });
  //console.log(debugTime() + 'jumpMenu.html: ' + h);
  $('#jumpMenu').html(h);
}

function initMenu() {
  $('#homeIcon').click(function() {
    console.log('homeIcon klick');
    window.location.href = '/';
  });
	
  $('#crosshairIcon').click(function() {
    console.log(debugTime() + 'crosshair klick');
    $('#hotspots').hide();
    $('#controls').hide();
    $('#share').hide();
    $('#report').hide();
    $('#menu').hide();

    if(!($('#mapid').length)) {
      // empty URLSearchParams means, show whole Germany
      createMap(new URLSearchParams());
    }
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var lat = position.coords.latitude;
        var lng = position.coords.longitude;
        console.log("Breite:" + lat + ", Laenge: " + lng);
	// jump to current location of user
        jump(lng, lat, 18);
      });
    } else {
      console.log('ERROR Keine Geo-Location-Unterstuetzung!');
    }
    if($('#mapid').length) {
      resizeMap();
    }
  });

  $('#flameIcon').click(function() {
    console.log('flameIcon klick');
    $('#hotspots').toggle();
    $('#controls').hide();
    $('#share').hide();
    $('#report').hide();
    $('#menu').hide();
    if($('#mapid').length) {
      resizeMap();
    };
    console.log('flameIcon klick end');
  });

  $('#layersIcon').click(function() {
    console.log(debugTime() + 'layersIcon klick');
    $('#hotspots').hide();
    $('#controls').toggle();
    $('#share').hide();
    $('#report').hide();
    $('#menu').hide();
    if($('#mapid').length) {
      resizeMap();
    }
  });

  $('#shareIcon').click(function() {
    console.log(debugTime() + 'shareIcon klick');
    $('#hotspots').hide();
    $('#controls').hide();
    $('#share').toggle();
    $('#report').hide();
    $('#menu').hide();
    if($('#mapid').length) {
      resizeMap();
    }
  });

  $('#penIcon').click(function() {
    console.log('penIcon klick');
    $('#hotspots').hide();
    $('#controls').hide();
    $('#share').hide();
    $('#report').toggle();
    $('#menu').hide();
    if($('#mapid').length) {
      resizeMap();
    }
  });

  $('#burgerIcon').click(function() {
    console.log('burgerIcon klick');
    $('#hotspots').hide();
    $('#controls').hide();
    $('#share').hide();
    $('#report').hide();
    $('#menu').toggle();
    if($('#mapid').length) {
      resizeMap();
    }
  });

  $('#impressum').click(function() {
    createImpressum();
  });
};

function formatNumber(num) {
  return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.")
}

function createHotspotsTable(headlineText, explainText, tableHeaderText, wsUrl) {
  console.log(debugTime() + 'createHotspotsTable()'); 

  $('#homeIcon').show();
  $('#layersIcon').hide();
  $('#shareIcon').hide();
	
  var h = '<div id="content">';
  h += '<h2>' + headlineText + '</h2>';
  if(explainText) {
    h += '<p>' + explainText + '</p>';
  }
  h += '<table>';
  h += '<thead><tr><th>#</th>';
  h += '<th>' + tableHeaderText + '</th>';
  h += '<th>Einwohner</th><th>Falschparker-Meldungen</th>';
  h += '<th>pro 100.000</th></tr></thead>';
  h += '</table>';
  h += '</div>';
  $('#main').html(h);

  $.getJSON('/gis/' + wsUrl, function (jsonResponseBody) {
    if(jsonResponseBody) {
      console.log("JSON WS /gis/grossstaedte successful: " + jsonResponseBody.ok);
      if(jsonResponseBody.ok) {
        h = '<tbody>'
        jsonResponseBody.boundaries.forEach( function(item, index) {
          h += "<tr>"
          h += '<td class="number">' + (index + 1) + '.</td>'
          h += '<td><a href="/?osmid=' + item.osm_id + '">' + item.name + '</a></td>'
          h += '<td class="number">' + formatNumber(item.ewz) + '</td>'
          h += '<td class="number">' + formatNumber(item.taten) + '</td>';
          h += '<td class="number">' + formatNumber(Math.round(item.pro_mil)) + '</td>';
        });
	h += '</tbody>';
        $(h).insertAfter('#content table thead');
      } else {
        console.log(jsonResponseBody.errorMessage);
      }
    } else {
      console.log("Couldn't download JSON-data");
    }
  });
}

function createMetropolises() {
  createHotspotsTable(
    'Gro&szlig;st&auml;dte',
    'Falschparker-Karte - Gro&szlig;st&auml;dte, Stadtstaaten und Kreise mit &uuml;ber 100.000 Einwohnern',
    'Stadt',
    'grossstaedte'
  );
}

function createBundeslaender() {
  console.log(debugTime() + 'createBundeslaender()'); 
  createHotspotsTable(
    'Bundesl&auml;nder',
    null,
    'Bundesland',
    'bundeslaender'
  );
}

function createRegierungsbezirke() {
  createHotspotsTable(
    'Regierungsbezirke',
    'Nur in Baden-W&uuml;rttemberg, Bayern, Hessen und Nordrhein-Westfalen gibt es Regierungsbezirke.',
    'Regierungsbezirk',
    'regierungsbezirke'
  );
}

function createMittlereGemeinden() {
  createHotspotsTable(
    'Mittlere Gemeinden',
    '... Mittelst&auml;dte, Kreise und Gemeinden mit 20.000 bis 100.000 Einwohnern',
    'Stadt/Gemeinde',
    'mittlere_gemeinden'
  );
}

function createImpressum() {
  $('#homeIcon').show();
  $('#layersIcon').hide();
  $('#shareIcon').hide();
  var h = `<div id="content">
    <h2>Impressum</h2>

    <p><img class="portrait" src="images/heiko_mit_helm.png" >Heiko Zelt<br>
      Uhlandstr. 16<br>
      65189 Wiesbaden<br>
      Deutschland</p>

    <p>Telefon/WhatsApp: +49 (0) 157 30 62 60 35<br>
      E-Mail: hz at heikozelt punkt de</p>

    <h2>&Uuml;ber mich</h1>

    <p>Ich habe mich oft &uuml;ber Falschparker auf "meinen" Radwegen, Gehwegen, vor meiner Ausfahrt, etc... ge&auml;rgert.
      Ich habe beim Ordnungsamt angerufen und sie haben mir gesagt, ich soll Falschparker mittels eines Formulars melden.
      So kam ich dann zur <a href="https://www.wegeheld.org/" target="_blank">Wegeheld</a>-App
      und zur <a href="https://www.weg-li.de/" target="_blank">Weg-li</a>-Website.
      Diese vereinfachen das Melden von Falschparkern.
      Wo gibt es Falschparker? Nur auf meinen Radwegen und Gehwegen oder auch anderswo?
      Und welche Verwaltung ist f&uuml;r die Verkehrs-&Uuml;berwachung zust&auml;ndig?
      Welche Kommunal-Politiker sind für den Bereich zust&auml;ndig?
      Um mir einen &Uuml;berblick zu verschaffen, habe ich diese Karte programmiert.
      Au&szlig;erdem wollte ich mich in Technologien einarbeiten, die mir bisher wenig oder gar nicht bekannt waren.</p>

    <p>Um etwas weiter auszuschweifen, ich &auml;rgere mich auch über die Luftverschmutzung, den Verkehrsl&auml;rm,
      den Fl&auml;chenverbrauch, die Todes-Opfer, etc..., die vom privaten Pkw-Verkehr verursacht werden.
      Ich bin Mitglied beim <a href="https://www.nabu.de/" target="_blank">NABU</a>
      und <a href="https://www.adfc.de/" target="_blank">ADFC</a>.
      In der Corona-Krise bin ich viel zu Hause und habe viel Zeit zum Programmieren.
      Ich habe aber auch andere Hobbys.
      Ich treibe gerne Sport, Radfahren, Joggen, Stand-Up-Paddeln und tanze Salsa und Lindy Hop.</p>

    <p>Ich selber besitze kein Auto, aber einen Motorroller und nutze gelegentlich Mietwagen und Car-Sharing.
      Ich fahre viel Rad. Seitdem ich ein Pedelec besitze, sogar noch mehr.
      Au&szlig;erdem nutze ich h&auml;ufig Bus und Bahn.
      Eine Straßenbahn gibt es hier in Wiesbaden leider noch nicht.
      Aber sie ist in Planung.
      Infos gibt es bei <a href="https://procitybahn.de/" target="_blank">B&uuml;rger Pro CityBahn</a>.</p>

    <h2>Daten-Quellen</h2>
    <ul>
      <li>Falschparker-Meldungen:
	<a href="https://www.weg-li.de/" target="_blank">weg-li.de</a> +
        <a href="https://www.wegeheld.org/" target="_blank">Wegeheld</a>
	(Die Daten werden w&ouml;chentlich, immer Montags kopiert.
	Mehrfach-Ordnungswidrigkeiten - z.B. Parken auf Gehweg und T&Uuml;V-Plakette abgelaufen - z&auml;hle ich nur einfach.)</li>
      <li>Einwohnerzahlen: <a href="https://www.zensus2011.de/" target="_blank">Zensus 2011</a></li>
      <li>Kartendaten und Verwaltungs-Grenzen: <a href="https://www.openstreetmap.org/" target="_blank">OpenStreetMap</a></li>
    </ul>
    </div>`
  $('div#main').html(h);
}

$(function() {
  console.log(debugTime() + 'map.js on load');
  init();
  createMap(new URLSearchParams(window.location.search));
  initHotspots();
  resizeMap();
  initMenu();

  // wenn sich Fenster-Groesse aendert,
  // und Karte existiert, dann Karten-Groesse anpassen
  $(window).resize(function() {
    console.log('window resize');
    resizeMap();
  });

  console.log(debugTime() + 'map.js onload end');
});
