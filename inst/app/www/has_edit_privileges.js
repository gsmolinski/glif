$( document ).ready(function() {
 Shiny.addCustomMessageHandler("edit_privileges", function(has_edit_privileges) {
   let pin_button = document.getElementById("glif_map-pin_btn");
   if (has_edit_privileges) {
     pin_button.style.visibility = "visible";
   } else {
     pin_button.style.visibility = "hidden";
   }
   Shiny.setInputValue("has_edit_privileges", has_edit_privileges);
 });
});
