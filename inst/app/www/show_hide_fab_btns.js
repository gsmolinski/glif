$( document ).ready(function() {
 Shiny.addCustomMessageHandler("show_hide_fab_btns", function(tab_id) {
   let fab_div = document.getElementById("fab_btn_layers");
   if (Shiny.shinyapp.$inputValues.is_inside_map) {
    if (tab_id == "architect_tab") {
          fab_div.style.visibility = "visible";
       } else if (tab_id == "map_tab") {
       fab_div.style.visibility = "hidden";
     }
   }
 });
});
