$('#partner').change(function() {


  console.log($('#partner').val());
  populateSelected();


})

function populateSelected()
{


  $('#bootstrap-duallistbox-nonselected-list_consul_services').append('<option value="apples">Apples</option> option:selected');
  //$('#bootstrap-duallistbox-nonselected-list_consul_services').bootstrapDualListbox('refresh');

}
