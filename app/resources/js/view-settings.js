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
	    $(".anhang").collapse('show');
	    $("#check_anhang").attr("checked","checked");
	}
	
	
	if (viewMode == "2") {
	    $("#check_auszeichnungen").attr("checked","checked");
	    $(".text-box").toggleClass("leseansicht");
	}
	
	
	if (viewMode == "") {
	    /*alert("Set URL-parameter view-mode")*/
        /*checken, ob Fragezeichen in der URL vorkommt*/
        var url = window.location.href
        var result = url.search(/\?/i);
        if (result == -1) {
            window.location = window.location + '?view-mode=1';
        }
        else {
            var params = getParams();
            var paramPos = url.search(/\?/i);
            var baseurl = url.substring(0,paramPos)
            var newurl = baseurl + "?" + "id=" + params["id"] + "&type=" + params["type"] + "&view-mode=1";
            window.location.href = newurl;
        }
        
	}
	/*Autoren verstecken*/
	$(".multiple .author").hide()
});

$("#check_auszeichnungen").click(function() {
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
    
    if ($("#check_auszeichnungen").attr("checked")!=="checked") {
        var newurl = baseurl + "?" + "id=" + params["id"] + "&type=" + params["type"] + "&show=" + params["show"] + "&view-mode=1";
        window.location.href = newurl;
    }
    else {
        var newurl = baseurl + "?" + "id=" + params["id"] + "&type=" + "&show=" + params["show"] + params["type"] + "&view-mode=2";
        window.location.href = newurl;
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
        var newurl = baseurl + "?id=" + params["prev"] + "&type=" + params['type'] + "&show=" + params["show"] + "&view-mode=" + params["view-mode"];
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


$("#toggle_doctype_L").click(function() {
    $(".doctype_L").toggle(this.checked);
});

$("#toggle_doctype_D").click(function() {
    $(".doctype_D").toggle(this.checked);
});

$("#toggle_doctype_T").click(function() {
    $(".doctype_T").toggle(this.checked);
});

/* Registerfilter */


/* Suchfeldfilter */
/* $("#filter_register").keyup(function(){
   
});*/



$("#filter_register").keyup(function(){
    
    // make contains caseinsensitive
jQuery.expr[':'].contains = function(a, i, m) {
 return jQuery(a).text().toLowerCase()
     .indexOf(m[3].toLowerCase()) >= 0;
};
    
    var $filter = $(this).val().toLowerCase();
    if ($filter) {
      /* "#register"*/
      $(".register").find("a:not(:contains(" + $filter + "))").hide();
      $(".register").find("a:contains(" + $filter + ")").show();
    } else {
      $(".register").find("a").show();
    }
});


/* Filter-Checkboxen*/
$("#toggle_register_P").click(function() {
    $(".register_person").toggle(this.checked);
    if ($("#toggle_register_P").attr("checked") !=="checked") {
        $(".multiple .author").show();
        $(".multiple .title").removeClass("hide_author");
    }
    else {
        $(".multiple .author").hide();
        $(".multiple .title").addClass("hide_author");
        
    }
});

$("#toggle_register_O").click(function() {
    $(".register_place").toggle(this.checked);
});

$("#toggle_register_T").click(function() {
    $(".register_biblFull").toggle(this.checked);
});

$("#toggle_register_Org").click(function() {
    $(".register_org").toggle(this.checked);
});


