$(function() {
	var row = $(this).closest('tr');
	var nRow = row[0];
	$('.dataTable').dataTable().fnDeleteRow(nRow);
	
  return true;
});