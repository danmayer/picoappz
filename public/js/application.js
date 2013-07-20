console.log('app running...');

$('#modal-gallery').on('load', function () {
  var modalData = $(this).data('modal');
  var img_link_url = $(modalData.$links[modalData.options.index]).data('url');
  $('.modal-download').attr('href', img_link_url);
});