$( document ).ready(function() {
  let map_tab = document.getElementById("glif_tabs-map_tab");
  let architect_tab = document.getElementById("glif_tabs-architect_tab");
  map_tab.classList.add("display-flex");
  map_tab.classList.add("flex-direction-column");
  map_tab.classList.add("justify-content-center");
  architect_tab.classList.add("display-flex");
  architect_tab.classList.add("flex-direction-column");
  architect_tab.classList.add("justify-content-center");

  $(document).on("shiny:connected", function() {
    Shiny.setInputValue("is_inside_map", false);
  });

 Shiny.addCustomMessageHandler("inside_map", function(is_inside_map) {
   Shiny.setInputValue("is_inside_map", is_inside_map);
   if (is_inside_map) {
     map_tab.classList.remove("display-flex");
     map_tab.classList.remove("flex-direction-column");
     map_tab.classList.remove("justify-content-center");
     architect_tab.classList.remove("display-flex");
     architect_tab.classList.remove("flex-direction-column");
     architect_tab.classList.remove("justify-content-center");
   } else {
     map_tab.classList.add("display-flex");
     map_tab.classList.add("flex-direction-column");
     map_tab.classList.add("justify-content-center");
     architect_tab.classList.add("display-flex");
     architect_tab.classList.add("flex-direction-column");
     architect_tab.classList.add("justify-content-center");
   }
 });
});
