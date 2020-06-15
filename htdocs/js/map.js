var falschparkerLayer = 0;
var boundaryLayer;
var markersLayerGroup;
var mymap = 0;
var chargeTypes = {};
var icons = new Array();

function resizeMap() {
  //alert('window:' + $(window).height() + ', header: ' + $('header').height() + '\nfooter: ' + $('footer').height());
  var mapHeight = $(window).height() - $('header').height() - $('footer').height();
  $('#mapid').height(mapHeight);	
  //setTimeout(function(){mymap.invalidateSize()}, 400);
  mymap.invalidateSize();
}

function transparenzAendern() {
  v = document.getElementById("transparenz").value;
  i = parseInt(v);
  o = (100 - i) / 100;
  falschparkerLayer.setOpacity(o);
  a = document.getElementById("transparenzAnzeige")
  a.innerHTML = v + ' %';
}

var noDetailText = '&#x1f6c8; <span style="font-style: italic;">Klicken Sie auf die Karte für Detail-Infos!</span> &#x1f6c8;';

function jump(lng, lat, zoomLevel) {
  mymap.setView(new L.LatLng(lat, lng), zoomLevel);
  // L.map('mapid').setView([y, x], z);
  $('#details').html(noDetailText);
}

function jumpBoundary(osmId) {
  console.log('jump to boundary ' + parseInt(osmId));
  var url = "/gis/boundary"
  $.getJSON(url + '?osmid=' + osmId, function (jsonResponseBody) {
    if(jsonResponseBody) {
      console.log("JSON WS /gis/boundary successful: " + jsonResponseBody.ok);
      if(jsonResponseBody.ok) {
	console.log('clear');
        boundaryLayer.clearLayers();
	console.log('add');
        boundaryLayer.addData(jsonResponseBody.way);
	console.log('fit');
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

function roundCoordinate(num) {
  return Math.round(num * 100000) / 100000;
}

function updateCoordinates() {
  console.log('updateCoordinates');
  bou = mymap.getBounds();
  console.log('Kartenausschnitt: W ' + bou.getWest() + ', E ' + bou.getEast() + ', S ' + bou.getSouth() + ', N ' + bou.getNorth());
  var qryStr = '?e=' + bou.getEast() + '&w=' + bou.getWest() + '&s=' + bou.getSouth() + '&n=' + bou.getNorth();
  $.getJSON('/gis/notices' + qryStr, function (jsonResponseBody) {
    if(jsonResponseBody) {
      console.log("JSON WS /gis/count successful: " + jsonResponseBody.ok);
      if(jsonResponseBody.ok) {
        $('#count').html(formatNumber(jsonResponseBody.count));
        markersLayerGroup.clearLayers();
	if(jsonResponseBody.notices) {
	  //now = new Date(jsonResponseBody.now);
	  //console.log("now as Date: " + now);
          console.log("length: " + jsonResponseBody.notices.length);
	  jsonResponseBody.notices.forEach(function (n, i) {
	    //console.log("notice: charge_id: " + n.charge_id + ", x: " + n.x + ", date: " + n.date);
            chargeType = chargeTypes[n.charge_id];
	    //console.log("charge: " + chargeType.name);
            ico = icons[chargeType.pin_id];
	    //console.log("icon: " + ico);
            d = new Date(n.date);
            datStr = ("0" + d.getDate()).slice(-2) + "." + ("0"+(d.getMonth()+1)).slice(-2) + "." +
              d.getFullYear() + ", " + ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2) + " Uhr";
	    switch(n.src) {
              case '1':
	        s = '<a href="https://www.wegeheld.org/" target="_blank">Wegeheld</a>';
		break;
              case '2':
	        s = '<a href="https://www.weg-li.de/" target="_blank">weg-li</a>';
                break;
              default:
                console.log("ERROR notice with unknown src");
	        s = '?'
	    }
            txt = chargeType.name + '<br>' + datStr + "<br>Quelle: " + s;
            //age = (now.getTime() - d.getTime()) / (24 * 60 * 60 * 1000);
	    //console.log("age: " + age);
            //opacity = 1 - (age / (365 * 3));
            //console.log("marker: y=" + n.y + " x=" + n.x + " chargeId=" + n.charge_id + " pin=" + chargeType.pin_id + " txt=" + txt)
            //L.marker([n.y, n.x], {icon: ico}).bindPopup(txt).setZIndexOffset(i).addTo(markersLayerGroup);
            L.marker([n.y, n.x], {icon: ico, zIndexOffset: i * 16}).bindPopup(txt).addTo(markersLayerGroup);
            //L.marker([n.y, n.x], {icon: ico}).bindPopup(txt).addTo(markersLayerGroup);
	  });
	}
      } else {
	console.log(jsonResponseBody.errorMessage);
      }
    } else {
      console.log("Couldn't download JSON-data");
    }
  });

  console.log('getCenter');
  var c = mymap.getCenter();
  x = roundCoordinate(c.lng);
  y = roundCoordinate(c.lat);
  console.log('getZoom');
  z = mymap.getZoom();
  console.log('gotZoom');
  var queryStr = '?x=' + x + '&y=' + y + '&z=' + z;
  var linkText = 'x: ' + x + ', y: ' + y + ', z: ' + z;
  var queryStrEscaped = queryStr.replace(/&/g, '%26');
  var hyperLink = window.location.href.split('?')[0] + queryStrEscaped
  $('#shareLink').attr('href', queryStr);
  $('#shareLink').html(linkText);
  $('#shareMail').attr('href', 'mailto:?subject=Falschparker-Karte&body=' + hyperLink);
  console.log('coordinates updated');
}

function updateCoordinatesOsmid(osmId) {
  console.log('updateCoordinatesOsmid');
  var queryStr = '?osmid=' + osmId;
  var linkText = 'OSM ID: ' + osmId;
  var queryStrEscaped = queryStr.replace(/&/g, '%26');
  var hyperLink = window.location.href.split('?')[0] + queryStrEscaped
  $('#shareLink').attr('href', queryStr);
  $('#shareLink').html(linkText);
  $('#shareMail').attr('href', 'mailto:?subject=Falschparker-Karte&body=' + hyperLink);
}


function formatNumber(num) {
  return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.")
}  

$(function() {
  console.log('map.js onload');
	
  for(i = 0; i <= 31; i++) {
    icons[i] = L.icon({
      iconUrl: 'pins/' + i.toString() + '.png',
      iconSize: [29, 33],
      iconAnchor: [11, 33]
    });
  }

  $.getJSON('/gis/charge_types', function(jsonResponseBody) {
    if(jsonResponseBody) {
      // Array in Dictionary umwandeln
      for(c of jsonResponseBody.chargeTypes) {
	chargeTypes[c.id] = {
	  pin_id: c.pin_id,
	  name: c.name
	}
      }
    }
  });
	
  $('#details').html(noDetailText);

  var urlParams = new URLSearchParams(window.location.search);
  console.log(urlParams.get('x'));

  mymap = L.map('mapid');
  if(urlParams.has('x') && urlParams.has('y') && urlParams.has('z')) {
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

  //mymap.on('zoomend', displayZoomLevel());
  mymap.on('zoomend', function(e) { updateCoordinates(); });
  mymap.on('moveend', function(e) { updateCoordinates(); });

  mymap.on('click', function(e) {
    lat = e.latlng.lat
    lng = e.latlng.lng
    console.log("clicked on Lat:" + lat + ", Lng:" + lng);
    //url = "dummy_ws.json"
    var url = "/gis/info"
    $.getJSON(url + '?lat=' + lat + '&lng=' + lng, function (jsonResponseBody) {
      if(jsonResponseBody) {
        console.log("JSON WS /gis/info successful: " + jsonResponseBody.ok);
	if(jsonResponseBody.ok) {
          if(jsonResponseBody.boundaries.length == 0) {
            h = "Bitte klicken Sie innerhalb Deutschlands! Außerhalb liegen keine Daten vor."
          } else {
            h = "<table>";
            h += "<tr><th>Verwaltungs-Einheit</th><th>Einwohner</th><th>Falschparker-Meldungen</th></tr>";
            jsonResponseBody.boundaries.forEach( function(item, index) {
              h += "<tr>"
              h += '<td><a onclick="jumpBoundary(' + item.osm_id + ');">' + item.name + '</a></td>';
              h += '<td class="number">' + formatNumber(item.ewz) + '</td>';
              h += '<td class="number">' + formatNumber(item.taten) + '</td>';
            });
            h += "</table>";
          }
        } else {
          console.log(jsonResonseBody.errorMessage);
	}
	//console.log(h);
        $('#details').html(h);
	resizeMap();
      } else {
	console.log("Couldn't download JSON-data");
      }
    });
  });

  targets = [ 
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
    {name: "Rhein-Main"      , zooom: 10, lat: 50.00497, lng:  8.37982 },
    {name: "Ruhr-Gebiet"     , zooom:  9, lat: 51.30978, lng:  6.92413 },
    {name: "Ulm"             , zooom: 12, lat: 48.38977, lng:  9.97919 }, // 2237
    {name: "Wiesbaden"       , zooom: 11, lat: 50.07515, lng:  8.23974 }  // 1520
  ];
  h = "";
  targets.forEach( function(item) {
    if(h != "") {
      h += ' ';
    }
    h += '<a onclick="jump(' + item.lng + ', ' + item.lat + ', ' + item.zooom + '); resizeMap();">' + item.name + '</a>' 
  });
  $('#jumpMenu').html(h);

  console.log('document load');
  resizeMap();

  $(window).resize(function() {
    console.log('window resize');
    resizeMap();
  });

  console.log('map.js onload end');
});
