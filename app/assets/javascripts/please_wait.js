$(document).ready(function(){
    $('.edit_update').on('click','.update_details',function () {
        $(this).removeClass('update_details')
        $(this).addClass('please_wait')
        $(this).attr("disabled", true);
    });
});
