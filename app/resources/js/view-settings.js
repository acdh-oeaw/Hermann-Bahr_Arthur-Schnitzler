function getUrlVar(key){
	var result = new RegExp(key + "=([^&]*)", "i").exec(window.location.search);
	return result && unescape(result[1]) || "";
}


$(document).ready(function() {
	var show = getUrlVar("show")
	if (show == "a") {
	    $("#anhang").collapse('show');
	    $("#check_anhang").attr("checked","checked");
}
});
