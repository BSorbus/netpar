window.setTimeout(function() {
//    $(".alert").fadeTo(1500, 0).slideUp(1500, function(){
    $(".alert").fadeTo(1000, 0).slideUp(1000, function(){
        $(this).remove(); 
    });
}, 60000);
