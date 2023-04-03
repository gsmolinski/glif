$( document ).ready(function() {
  Shiny.addCustomMessage("copy_edit_code", function(edit_code) {
    navigator.clipboard.writeText(edit_code);
  });
});
