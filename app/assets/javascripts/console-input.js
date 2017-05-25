$(document).ready(function(){
    $('.consolelike').each(function(){
        var faux = $(this).find('.fauxInput');
        var input = $(this).find('.consolelike-input');

        input.on('input', function(){
            faux.text(input.val());
            input.attr('value', input.val());
        });

        console.log('initialized');
    });
});