$(function() {
  $('.datepicker').datepicker( {
      showButtonPanel: false,
      showOtherMonths: false,
      selectOtherMonths: false,
      changeMonth: true,
      changeYear: true,
      yearRange: "1900:2040",
      showAnim: "show",
			closeText: 'Zamknij',
			prevText: '&#x3C;Poprzedni',
			nextText: 'Następny&#x3E;',
			currentText: 'Dziś',
			monthNames: ['Styczeń','Luty','Marzec','Kwiecień','Maj','Czerwiec',
			'Lipiec','Sierpień','Wrzesień','Październik','Listopad','Grudzień'],
			monthNamesShort: ['Sty','Lu','Mar','Kw','Maj','Cze',
			'Lip','Sie','Wrz','Pa','Lis','Gru'],
			dayNames: ['Niedziela','Poniedziałek','Wtorek','Środa','Czwartek','Piątek','Sobota'],
			dayNamesShort: ['Nie','Pn','Wt','Śr','Czw','Pt','So'],
			dayNamesMin: ['N','Pn','Wt','Śr','Cz','Pt','So'],
			weekHeader: 'Tydz',
			dateFormat: 'yy-mm-dd',
			firstDay: 1,
			isRTL: false,
			showMonthAfterYear: false,
			yearSuffix: ''
    });
  });

