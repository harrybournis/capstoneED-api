$(function() {
	if ($(window).width() >= 768) {
		$('#nav').affix({
		    offset: {
		      top: $('#nav').offset().top//,
		      //bottom: ($('footer').outerHeight(true) + $('.application').outerHeight(true)) + 40
		    }
		});
	}
});
