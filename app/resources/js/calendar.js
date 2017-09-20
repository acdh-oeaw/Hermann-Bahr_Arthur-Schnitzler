
$(document).ready(function() {
    url= window.location.href
    baseurl = url.substring(0,url.indexOf('calendar.html'))
    /*Data laden*/
    /* Achtung url muss man dann dynamisch setzen */
    var $data = (function () {
    var json = null;
    $.ajax({
        'async': false,
        'global': false,
        'url': baseurl + "/data.xql",
        'dataType': "json",
        'success': function (data) {
            json = data;
        }
    });
    return json;
})();



var $dataSource = [];
$.each( $data, function( key, entry ) {
  var $obj = {};
  var $j = entry.sortDate.substring(0,4);
  var $m = entry.sortDate.substring(5,7);
  var $d = entry.sortDate.substring(8,10);
  $obj.endDate = new Date($j,$m-1,$d);
  $obj.startDate = new Date($j,$m-1,$d);
  $obj.id = entry.id;
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

var $disabledDays = [];
    
    /*new Date(1891,0,2)*/
	
	
	$('#calendar').calendar({
        dataSource: $dataSource,
        startYear: 1891,
        disabledDays: $disabledDays,
        minDate : new Date(1891,0,1),
        maxDate : new Date(1963,0,1),
        language: "de",
        style: "background"
    });
    
$('#calendar').clickDay(function(e){ 
    var ids = []
    $.each(e.events, function( key, entry ) {
        ids.push(entry.id)
    });
    /*alert(ids.join())*/
    window.location = baseurl + "/view.html" + "?id=" + ids.join()
    
    
    
    /*
    $date = e.events[0].startDate
    alert($date);
    $j = $date.getFullYear()
    $m = $date.getMonth()+1
    $d = $date.getDate()
    alert($j + '-' + $m + '-' + $d)
    */
    /*alert(e.events[0].id)*/
    
});
   
   $(".day:not(.day-start)").addClass("disabled");
    
});

