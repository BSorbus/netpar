$(window).scroll(function() { 
//  if ($(this).scrollTop() < 850)
  if ($(this).scrollTop() < 2000)
    {
      $(".userbar").slideUp("slow");   
    } 
  else
    {     
      $(".userbar").slideDown("slow");
    }
});