$( document ).ready(function() {
 Shiny.addCustomMessageHandler("change_nav_text", function(tab_id) {
   let glif_name = document.getElementById("glif_name_nav_id");
   let glif_desc = document.getElementById("glif_desc_nav_id");
   if (tab_id === "map_tab") {
    glif_name.textContent = "glif";
    glif_desc.textContent = "stands for visibility";
   } else {
    glif_name.textContent = "";
    glif_desc.textContent = "... and for architects";
   }
 });
});
