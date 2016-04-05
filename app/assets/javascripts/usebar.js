$(window).scroll(function() { 
//  if ($(this).scrollTop() < 850)
  if ($(this).scrollTop() < 1100)
    {
      $(".userbar").slideUp("slow");   
    } 
  else
    {     
      $(".userbar").slideDown("slow");
    }
});