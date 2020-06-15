$(function () {
  console.log('menu.js onload');

  $('#hamburger').click(function() {
    console.log('hamburger klick');
    $('#report').hide();
    var x = $('#menu');
    if (x.is(':visible')) {
      x.hide();
    } else {
      x.show();
    };
    if($('#mapid').length) {
      resizeMap();
    }
  });

  $('#nemo').click(function() {
    console.log('nemo klick');
    $('#menu').hide();
    var x = $('#report');
    if (x.is(':visible')) {
      x.hide();
    } else {
      x.show();
    };
    if($('#mapid').length) {
      resizeMap();
    }
  });
  console.log('menu.js onload end');
});
