function getUrlVar(key){
	var result = new RegExp(key + "=([^&]*)", "i").exec(window.location.search);
	return result && unescape(result[1]) || "";
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
    var url = $("#prev").attr("href");
    var pos = url.search("show");
    
    if ($("#check_anhang").attr("checked")!=="checked") {
    /* alert("Parameter entfernen"); */  
    if (pos !== -1) {
        var sln = url.length;
        var showLen = sln - pos
        var show = url.slice(pos, sln)
        urlnoshow = url.slice(0, pos)
        /* alert("show: " + show + " showLen: " + showLen + " pos: " + pos+ " url-no-show: " + urlnoshow) */
        /*neue url*/
        $("#prev").attr("href", newurl)
        /* alert(newurl) */
    }
     
    }/*Ende 1. if*/
    else {
        /*War nicht angewählt*/
        /* alert("show hinzufügen") */
        if ($("#check_kommentar").attr("checked")=="checked") {
            /* BESTE VARIANTE – nur das so implementieren, dafür bei #prev und #next ersetzen */
            url = url.replace("&show=","&show=a")
            /* alert("neue url: " + url) */
            $("#prev").attr("href", url)
            $("#next").attr("href", url)
        }
    }
});



$("#select-view-mode").change(function(){
    /*alert($("#select-view-mode").val());*/
    if ($("#select-view-mode").val()=='Erweiterte Ansicht') {
        $(".text-box").removeClass("leseansicht").addClass("text-box");
        var url = $("#prev").attr("href");
        newurl = url.replace("&view-mode=1","&view-mode=2");
        $("#prev").attr("href", newurl);
        $("#next").attr("href", newurl);
    }
    if ($("#select-view-mode").val()=='Leseansicht') {
        $(".text-box").addClass("leseansicht");
        var url = $("#prev").attr("href");
        newurl = url.replace("&view-mode=2","&view-mode=1");
        $("#prev").attr("href", newurl);
        $("#next").attr("href", newurl);
    }
    
});

