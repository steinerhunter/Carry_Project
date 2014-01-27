$(function() {
    $(".modal-link").click(function(event) {
        event.preventDefault();
        var target = $(this).attr("href");
        $('#myModal').removeData("modal");
        $('#signinModal').removeData("modal");
        $('#signupModal').removeData("modal");
        $('#phoneAddModal').removeData("modal");
        $('#phoneVerifyModal').removeData("modal");
        $("#giveAwayModal .modal-body").load(target, function() {
            $("#giveAwayModal").modal("show");
        });
    })
})
