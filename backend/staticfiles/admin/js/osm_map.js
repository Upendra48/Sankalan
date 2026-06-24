document.addEventListener("DOMContentLoaded", function () {
  const latitudeInput = document.getElementById("id_latitude");
  const longitudeInput = document.getElementById("id_longitude");
  

  // Default location (Pokhara as an example)
  const defaultLocation = [parseFloat(latitudeInput.value) || 28.261336, parseFloat(longitudeInput.value) || 83.971944];

  // Create map container
  const mapContainer = document.createElement("div");
  mapContainer.style.width = "100%";
  mapContainer.style.height = "400px";
  mapContainer.style.marginTop = "10px";

  // Add map container to the form
  longitudeInput.parentElement.appendChild(mapContainer);

  // Initialize the map
  const map = L.map(mapContainer).setView(defaultLocation, 16);

  // Add OpenStreetMap tiles
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map);

  // Add a draggable marker
  const marker = L.marker(defaultLocation, { draggable: true }).addTo(map);

  // Update latitude and longitude inputs on marker drag
  marker.on("dragend", function (event) {
    const position = marker.getLatLng();
    latitudeInput.value = position.lat.toFixed(6);
    longitudeInput.value = position.lng.toFixed(6);
  });

  // Update marker position if user edits latitude or longitude inputs
  latitudeInput.addEventListener("change", () => {
    const newLat = parseFloat(latitudeInput.value) || defaultLocation[0];
    const newLng = parseFloat(longitudeInput.value) || defaultLocation[1];
    marker.setLatLng([newLat, newLng]);
    map.setView([newLat, newLng]);
  });

  longitudeInput.addEventListener("change", () => {
    const newLat = parseFloat(latitudeInput.value) || defaultLocation[0];
    const newLng = parseFloat(longitudeInput.value) || defaultLocation[1];
    marker.setLatLng([newLat, newLng]);
    map.setView([newLat, newLng]);
  });
});
