$(document).ready(function(){
    $('.edit_picture').on('click','.update_details',function () {
        $(this).removeClass('update_details');
        $(this).addClass('please_wait');
        $(this).prop("value", "Please wait...");
        $(this).prop("disabled", true);
        $('#edit_picture').submit()
    });
});
