$( document ).ready(function() {
  Shiny.addCustomMessageHandler("copy_edit_code", function(edit_code) {
    navigator.clipboard.writeText(edit_code);
  });
});
