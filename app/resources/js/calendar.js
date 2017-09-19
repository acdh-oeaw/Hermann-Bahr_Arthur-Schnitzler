
$(document).ready(function() {
    
    /*Data laden*/
    /* Achtung url muss man dann dynamisch setzen */
    var $data = (function () {
    var json = null;
    $.ajax({
        'async': false,
        'global': false,
        'url': "http://localhost:8080/exist/apps/hbas/data.xql",
        'dataType': "json",
        'success': function (data) {
            json = data;
        }
    });
    return json;
})();

var $dataSource = (function () {
    var json = null;
    $.ajax({
        'async': false,
        'global': false,
        'url': "http://localhost:8080/exist/apps/hbas/data.xql",
        'dataType': "json",
        'success': function (data) {
            json = data;
        }
    });
    return json;
})();

/* var $dataSource = [ {
  name : "Tagebuch von Schnitzler, 27. 4. 1891",
  startDate : new Date(1891,00,1),
  endDate : new Date(1891,0,1)
}, {
  name : "Tagebuch von Schnitzler, 28. 4. 1891",
  startDate : new Date(1891,03,28),
  endDate : new Date(1891,03,28)
}, {
  "name" : "E. M. Kafka an Bahr, 12. 8. 1891",
  "startDate" : new Date(1891,07,12),
  "endDate" : new Date(1891,07,12),
  "id" : "L041646"
  
}
]
*/


var $dataSource = [];
$.each( $data, function( key, entry ) {
  var $obj = {};
  var $j = entry.sortDate.substring(0,4);
  var $m = entry.sortDate.substring(5,7);
  var $d = entry.sortDate.substring(8,10);
  $obj.endDate = new Date($j,$m-1,$d);
  $obj.startDate = new Date($j,$m-1,$d);
  $dataSource.push($obj);
});


/*
alert($data[1].sortDate)
var $j = $data[1].sortDate.substring(0,4);
var $m = $data[1].sortDate.substring(5,7);
var $d = $data[1].sortDate.substring(8,10);
alert($j);
alert($m);
alert($d);
*/

var $disabledDays = [
            new Date(1891,0,2)
        ]
    
    
	$('#calendar').calendar({
        dataSource: $dataSource,
        startYear: 1891,
        disabledDays: $disabledDays
    });
});
