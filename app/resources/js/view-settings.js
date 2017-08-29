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
        document.location = document.location + '&view-mode=1';
	}
});

$("#check_anhang").click(function() {
    /*wenn Paramenter nicht da, in url hinzufügen + href von vor/zurück anpassen*/
    var url = document.location;
    alert(url);
    /*Parameter finden*/
    var params = getParams();
    alert("prev= " + params["prev"]+ " |next= " + params["next"]);
    
     /* alert("id=" + params["id"] + " view-mode=" + params["view-mode"] + " show=" + params["show"] + " type=" + params["type"] + " prev=" + params["prev"] + " next=" + params["next"]) */
    
    if ($("#check_anhang").attr("checked")!=="checked") {
    alert("Parameter entfernen"); 
    }
    
});

