$(document).ready(function() {
    $('#EVE_fileupload').on('submit', function(e){
        e.preventDefault();
        $.ajax({
            url: "/request_deliveries/79/take?type=take",
            type: 'PUT',
            success: function(result) {
            }
        });
    })
})
