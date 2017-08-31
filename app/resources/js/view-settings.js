function getUrlVar(key){
	var result = new RegExp(key + "=([^&]*)", "i").exec(window.location.search);
	return result && unescape(result[1]) || "";
}


function getParams() {
    
    /*vorangehendes+folgendes Dokument*/
    var prevUrl = $("#prev").attr("href");
    var prevPos = prevUrl.search(/id=/i);
    var prev = prevUrl.substring(prevPos+3,prevPos+10)
    
    var nextUrl = $("#next").attr("href");
    var nextPos = nextUrl.search(/id=/i);
    var next = nextUrl.substring(nextPos+3,nextPos+10)
    
    
    var params = {}
    params["id"] = getUrlVar("id");
    params["show"] = getUrlVar("show");
    params["type"] = getUrlVar("type");
    params["view-mode"] = getUrlVar("view-mode");
    params["prev"] = prev;
    params["next"] = next
    return params
}


$(document).ready(function() {
	var show = getUrlVar("show")
	var viewMode = getUrlVar("view-mode")
	
	if (show.indexOf("a") !== -1) {
	    $("#anhang").collapse('show');
	    $("#check_anhang").attr("checked","checked");
	}
	
	if (viewMode == "2") {
	    $("#select-view-mode").val('Erweiterte Ansicht');
	    $(".text-box").toggleClass("leseansicht");
	}
	
	if (viewMode == "") {
	    /*alert("Set URL-parameter view-mode")*/
        /*checken, ob Fragezeichen in der URL vorkommt*/
        var url = window.location.href
        var result = url.search(/\?/i);
        if (result == -1) {
            document.location = document.location + '?view-mode=1';
        }
        else {
           document.location = document.location + '&view-mode=1'; 
        }
        
	}
});

$("#check_anhang").click(function() {
    /*wenn Paramenter nicht da, in url hinzufügen + href von vor/zurück anpassen*/
    var url = window.location.href;
    /* alert(url); */
    /*Parameter finden*/
    var params = getParams();
    
    /*baseurl*/
    /* URL anpassen */
    var paramPos = url.search(/\?/i);
    var baseurl = url.substring(0,paramPos)
    
    /* alert("prev= " + params["prev"]+ " | next= " + params["next"]); */
    
     /* alert("id=" + params["id"] + " view-mode=" + params["view-mode"] + " show=" + params["show"] + " type=" + params["type"] + " prev=" + params["prev"] + " next=" + params["next"]) */
    
    if ($("#check_anhang").attr("checked")!=="checked") {
    /* Anhang ist angewählt, soll entfernt werden */
    /* alert("Parameter entfernen"); */ 
    /* alert("Baseurl: " + baseurl) */
    var newurl = baseurl + "?" + "id=" + params["id"] + "&type=" + params["type"] + "&view-mode=" + params["view-mode"];
        window.location.href = newurl;
    }
    else {
            var newurl = baseurl + "?" + "id=" + params["id"] + "&type=" + params["type"] + "&show=a" + "&view-mode=" + params["view-mode"];
    window.location.href = newurl;
    }
});


$("#select-view-mode").change(function(){
    /*alert($("#select-view-mode").val());*/
    var params = getParams();
    var url = window.location.href;
    var paramPos = url.search(/\?/i);
    var baseurl = url.substring(0,paramPos)
    
    if ($("#select-view-mode").val()=='Erweiterte Ansicht') {
        var newurl = baseurl + "?id=" + params["id"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=2"
    window.location.href = newurl;    
    }
    if ($("#select-view-mode").val()=='Leseansicht') {
        var newurl = baseurl + "?id=" + params["id"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=1"
    window.location.href = newurl;    
    }
    });

$(".commentary-ref").click(function() {
    var params = getParams();
    if (params["show"] !== "a") {
      $("#anhang").collapse('show');  
    }
    
    
});

/*Steuerung per Cursor*/

$(document).keydown(function(e) {
    var params = getParams();
    var url = window.location.href;
    var paramPos = url.search(/\?/i);
    var baseurl = url.substring(0,paramPos)
    switch(e.which) {
        case 37: // left
        /* load prev */
        /* alert("Arrow left")*/
        /* alert(params["prev"]) */
        var newurl = baseurl + "?id=" + params["prev"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=" + params["view-mode"]
    window.location.href = newurl;  
        break;

        case 39: // right
        /* alert("Arrow right"); */
        var newurl = baseurl + "?id=" + params["next"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=" + params["view-mode"]
    window.location.href = newurl;
        break;

        default: return; // exit this handler for other keys
    }
    e.preventDefault(); // prevent the default action (scroll / move caret)
});

/* Mobile: Steuerung per swipeleft/swiperight */

$("#content-box").on("swipeleft",function(){
  /*Zurück*/
    var params = getParams();
    var url = window.location.href;
    var paramPos = url.search(/\?/i);
    var baseurl = url.substring(0,paramPos)
    var newurl = baseurl + "?id=" + params["prev"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=" + params["view-mode"]
    window.location.href = newurl;
});

$("#content-box").on("swiperight",function(){
  /*nächstes Dokument*/
    var params = getParams();
    var url = window.location.href;
    var paramPos = url.search(/\?/i);
    var baseurl = url.substring(0,paramPos)
    var newurl = baseurl + "?id=" + params["next"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=" + params["view-mode"]
    window.location.href = newurl;
});


