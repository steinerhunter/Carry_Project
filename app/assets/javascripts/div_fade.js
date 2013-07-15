$(document).ready(function(){
    $('#PassSomething').click(function(e){
        e.preventDefault();
        $('#main_div').fadeOut('slow', function(){
            $('#pass_div').fadeIn('slow');
        });
    });
    $('#SendSomething').click(function(e){
        e.preventDefault();
        $('#main_div').fadeOut('slow', function(){
            $('#send_div').fadeIn('slow');
        });
    });
    $('#back_pass_id').click(function(e){
        e.preventDefault();
        $('#pass_div').fadeOut('slow', function(){
            $('#main_div').fadeIn('slow');
        });
    });
    $('#back_send_id').click(function(e){
        e.preventDefault();
        $('#send_div').fadeOut('slow', function(){
            $('#main_div').fadeIn('slow');
        });
    });
});