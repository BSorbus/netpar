$(window).scroll(function() { 
  if ($(this).scrollTop() < 850)
    {
      $(".userbar").slideUp("slow");   
    } 
  else
    {     
      $(".userbar").slideDown("slow");
    }
});