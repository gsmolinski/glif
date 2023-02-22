$( document ).ready(function() {
 Shiny.addCustomMessageHandler("get_geolocation", function(arrrr) {
   navigator.geolocation.getCurrentPosition(success, error);

   function error(err) {
     Shiny.setInputValue("geolocation", false);
   }

   function success(pos) {
     Shiny.setInputValue("geolocation", true);
     Shiny.setInputValue("geolocation_lat", pos.coords.latitude);
     Shiny.setInputValue("geolocation_lng", pos.coords.longitude);
   }
 });
});
