$(window).scroll(function() { 
  if ($(this).scrollTop() < 650)
    {
      $(".userbar").slideUp("slow");   
    } 
  else
    {     
      $(".userbar").slideDown("slow");
    }
});