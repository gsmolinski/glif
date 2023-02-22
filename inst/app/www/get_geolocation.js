$( document ).ready(function() {
 Shiny.addCustomMessageHandler("get_geolocation", function(arrrr) {
   navigator.geolocation.getCurrentPosition(success, error);

   function error(err) {
     Shiny.onInputChange("geolocation", false);
   }

   function success(pos) {
     Shiny.onInputChange("geolocation", true);
     Shiny.onInputChange("geolocation_lat", pos.coords.latitude);
     Shiny.onInputChange("geolocation_long", pos.coords.longitude);
   }
 });
});
