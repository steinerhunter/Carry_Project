$(function() {
    $(".modal-link").click(function(event) {
        event.preventDefault();
        $('#myModal').removeData("modal");
        $('#signinModal').removeData("modal");
        $('#signupModal').removeData("modal");
    })
})
