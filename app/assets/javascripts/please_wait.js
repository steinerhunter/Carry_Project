$(document).ready(function(){
    $('.edit_update').on('click','.update_details',function () {
        $(this).removeClass('update_details');
        $(this).addClass('please_wait');
        $(this).prop("value", "Please wait...");
        $(this).prop("disabled", true);
        if($('#new_request_delivery').length) {
            $('#new_request_delivery').submit()
        }
        else if($('#edit_picture').length) {
            $('#edit_picture').submit()
        }
    });
});
