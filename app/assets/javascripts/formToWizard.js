(function($) {
    $.fn.formToWizard = function(options) {
        options = $.extend({  
            submitButton: "" 
        }, options);

        var $input_id;

        $('input').click(
            function(){
                if ($(this).attr('class') == "address_field") {
                    $input_id = $(this).attr('id');
                    var input = document.getElementById($input_id);
                    var autocomplete = new google.maps.places.Autocomplete(input);
                }
            });

        var element = this;
        $(element).enableClientSideValidations();

        var steps = $(element).find("fieldset");
        var count = steps.size();
        var submitButtonName = "#" + options.submitButton;
        $(submitButtonName).hide();

        // 2
        $(element).before("<ul id='steps'></ul>");

        steps.each(function(i) {
            $(this).wrap("<div class= 'step_class' id='step" + i + "'></div>");
            $(this).append("<div class='step_command' id='step" + i + "commands'></div>");

            // 2
            var name = $(this).find("legend").html();
            $("#steps").append("<li id='stepDesc" + i + "'>Step " + (i + 1) + "<span>" + name + "</span></li>");

            if (i == 0) {
                createNextButton(i);
                selectStep(i);
            }
            else if (i == count - 1) {
                $("#step" + i).hide();
                createPrevButton(i);
                createFinishButton(i);
            }
            else {
                $("#step" + i).hide();
                createPrevButton(i);
                createNextButton(i);
            }
        });

        function createPrevButton(i) {
            var stepName = "step" + i;
            $("#" + stepName + "commands").append("<a href='#' id='" + stepName + "Prev' class='prev'>Back</a>");

            $("#" + stepName + "Prev").bind("click", function(e) {
                $("#" + stepName).fadeOut();
                $("#step" + (i - 1)).delay(800).fadeIn();
                $(submitButtonName).hide();
                selectStep(i - 1);
            });
        }

        function createNextButton(i) {
            var stepName = "step" + i;
            $("#" + stepName + "commands").append("<a href='#' id='" + stepName + "Next' class='next'>Next</a>");
            $("#" + stepName + "Next").bind("click", function(e) {
                var valid = true;
                $('[data-validate]:input:visible').each(function() {
                    var settings = window.ClientSideValidations.forms[this.form.id]
                    if (!$(this).isValid(settings.validators)) {
                        valid = false
                    }
                });
                if(valid){
                    $("#" + stepName).fadeOut();
                    $("#step" + (i + 1)).delay(800).fadeIn();
                    if (i + 2 == count)
                        $(submitButtonName).show();
                    selectStep(i + 1);
                }
                return valid;
            });
        }

        function createFinishButton(i) {

            var stepName = "step" + i;
            $("#" + stepName + "commands").append($(".finish").clone()).html();
            $(".form_submit").remove();

            $("#" + stepName + "Next").bind("click", function(e) {
                $("#" + stepName).fadeOut();
                $("#step" + (i + 1)).delay(800).fadeIn();
                if (i + 2 == count)
                    $(submitButtonName).show();
                selectStep(i + 1);
            });
        }

        function selectStep(i) {
            $("#steps li").removeClass("current");
            $("#stepDesc" + i).addClass("current");
        }

    }
})(jQuery); 