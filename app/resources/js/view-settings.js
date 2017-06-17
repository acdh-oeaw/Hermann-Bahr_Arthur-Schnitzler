function getUrlVar(key){
	var result = new RegExp(key + "=([^&]*)", "i").exec(window.location.search);
	return result && unescape(result[1]) || "";
}

/*var string = "foo",
    substring = "oo";
string.indexOf(substring) !== -1;
String.prototype.indexOf returns the position of the string in the other string. If not found, it will return -1.
*/


$(document).ready(function() {
	var show = getUrlVar("show")
	if (show.indexOf("a") !== -1) {
	    $("#anhang").collapse('show');
	    $("#check_anhang").attr("checked","checked");
	}
		if (show.indexOf("k") !== -1) {
	    $("#kommentar").collapse('show');
	    $("#check_kommentar").attr("checked","checked");
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
        if ($("#check_kommentar").attr("checked")=="checked") {
            /*an url show=k dranhängen*/
            var newurl= urlnoshow.concat("show=k")
            $
        } else {
            var newurl = urlnoshow
        }
        $("#prev").attr("href", newurl)
        /* alert(newurl) */
    }
     
    }/*Ende 1. if*/
    else {
        /*War nicht angewählt*/
        /* alert("show hinzufügen") */
        if ($("#check_kommentar").attr("checked")=="checked") {
            /* BESTE VARIANTE – nur das so implementieren, dafür bei #prev und #next ersetzen */
            url = url.replace("show=k","show=a,k")
            /* alert("neue url: " + url) */
            $("#prev").attr("href", url)
        }
    }
});

$("#check_kommentar").click(function() {
    /*wenn Paramenter nicht da, in url hinzufügen + href von vor/zurück anpassen*/
    
    
});

