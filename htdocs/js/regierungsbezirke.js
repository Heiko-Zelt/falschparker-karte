$(function() {
  function formatNumber(num) {
    return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.")
  }  

  $.getJSON("/gis/regierungsbezirke", function (jsonResponseBody) {
    if(jsonResponseBody) {
      console.log("JSON WS /gis/regierungsbezirke successful: " + jsonResponseBody.ok);
      if(jsonResponseBody.ok) {
        h = "<table>"
        h += "<tr><th>#</th><th>Regierungsbezirk</th><th>Einwohner</th><th>Falschparker-Meldungen</th><th>pro 100.000</th></tr>"
        jsonResponseBody.boundaries.forEach( function(item, index) {
          h += "<tr>"
          h += '<td class="number">' + (index + 1) + '.</td>'
          h += '<td><a href="/?osmid=' + item.osm_id + '">' + item.name + '</a></td>'
          h += '<td class="number">' + formatNumber(item.ewz) + '</td>'
          h += '<td class="number">' + formatNumber(item.taten) + '</td>';
          h += '<td class="number">' + formatNumber(Math.round(item.pro_mil)) + '</td>';
        });
        h += "</table>";
        $('#main').html(h);
      } else {
        console.log(jsonResponseBody.errorMessage);
      }
    } else {
      console.log("Couldn't download JSON-data");
    }
  });
});
