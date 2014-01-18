$(document).ready(function() {
    $("#phone_verify_form").submit(function(e) {
        e.preventDefault();
        $.ajax({
            url: "/request_deliveries/"+gon.request_delivery.id+"/accept?type=accept",
            type: 'PUT',
            success: function(result) {
            }
        });
    })
})
