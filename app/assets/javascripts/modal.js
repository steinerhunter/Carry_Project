$(function() {
    $(".modal-link").click(function(event) {
        event.preventDefault();
        $('#myModal').removeData("modal");
    })
})
