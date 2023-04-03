$( document ).ready(function() {
  let ids_input = [];
 Shiny.addCustomMessageHandler("get_changed_card_input", function(ids_from_shiny) {
   ids_input.length = 0;
   for (let id_one of ids_from_shiny) {
     ids_input.push(id_one);
   }
 });
 $(document).on("shiny:inputchanged", function(e) {
  if (ids_input.includes(e.name) && e.value) {
    Shiny.setInputValue("changed_card_input", [e.name, e.value]);
  }
 });
});
