$(document).ready(function(){
    $('#PassSomething').click(function(e){
        e.preventDefault();
        $('#main_div').fadeOut('slow', function(){
            $('#pass_div').fadeIn('slow');
        });
    });
    $('#SendSomething').click(function(e){
        e.preventDefault();
        $('#main_div').fadeOut('fast', function(){
            $('#send_div').fadeIn('fast');
        });
    });
});