(function($) {
    $.fn.mapsAndDate = function(options) {
        options = $.extend({
            submitButton: ""
        }, options);

        var $input_id;

        $('input').click(
            function(){
                if ($(this).attr('class') == "address_field") {
                    $input_id = $(this).attr('id');
                    var input = document.getElementById($input_id);
                    var autocomplete = new google.maps.places.Autocomplete(input);
                }
            });
        $('.datepicker').datepicker({
            format: 'dd/mm/yyyy'
        });
    }
})(jQuery);