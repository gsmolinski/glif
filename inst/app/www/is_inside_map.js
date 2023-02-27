$( document ).ready(function() {
  $(document).on("shiny:connected", function() {
    Shiny.setInputValue("is_inside_map", false);
  });
 Shiny.addCustomMessageHandler("inside_map", function(is_inside_map) {
   Shiny.setInputValue("is_inside_map", is_inside_map);
 });
});
