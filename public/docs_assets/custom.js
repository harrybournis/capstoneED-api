$(function() {
	if ($(window).width() >= 768) {
		$('#nav').affix({
		    offset: {
		      top: $('#nav').offset().top//,
		      //bottom: ($('footer').outerHeight(true) + $('.application').outerHeight(true)) + 40
		    }
		});
	}
	var body = document.getElementById("body");
});



function animateBackground () {
	body.className = "jelly";
};

function stopAnimatingBackground () {
	body.className = "";
};
