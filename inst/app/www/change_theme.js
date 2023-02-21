$( document ).ready(function() {
 Shiny.addCustomMessageHandler("change_theme", function(dark_requested) {
   let app_theme = document.getElementById("app").firstElementChild;
   if (dark_requested) {
     app_theme.classList.remove("theme-dark");
     app_theme.classList.add("theme-light");
   } else {
     app_theme.classList.remove("theme-light");
     app_theme.classList.add("theme-dark");
   }
 });
});
