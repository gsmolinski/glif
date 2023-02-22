$( document ).ready(function() {
 Shiny.addCustomMessageHandler("change_theme", function(dark_requested) {
   let app_theme = document.getElementById("app").firstElementChild;
   let button_theme = document.getElementById("toggle_theme");
   if (dark_requested) {
     app_theme.classList.remove("theme-dark");
     app_theme.classList.add("theme-light");
     button_theme.style.color = "#717172";
     button_theme.style.background = "#CBC8C3";
     button_theme.style.background = "linear-gradient(90deg, #CBC8C3 46%, #3C3C3B 100%)";
   } else {
     app_theme.classList.remove("theme-light");
     app_theme.classList.add("theme-dark");
     button_theme.style.color = "#989898";
     button_theme.style.background = "#3C3C3B";
     button_theme.style.background = "linear-gradient(90deg, #3C3C3B 46%, #CBC8C3 100%)";
   }
 });
});
