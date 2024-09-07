import {Controller} from "@hotwired/stimulus"
import L from "leaflet"
import {get} from "@rails/request.js"

// Connects to data-controller="map"
export default class extends Controller {
    static targets = ["container"]

    connect() {
        this.createMap();
        this.map.setView([-25.263741, -57.575928], 12);
    }

    createMap() {
        // init empty map inside container target
        this.map = L.map(this.containerTarget);

        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19, attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(this.map);

        this.getCoordinates();
    }

    // Can be improved with a simple fetch from rails
    getCoordinates() {
        get("/museums/coordinates", {responseKind: "json"})
            .then(response => {
                if (response.ok) {
                    response.json.then((json) => {
                        json.forEach((museum) => {
                            L.marker([museum.latitude, museum.longitude])
                                .bindPopup(`${museum.name}`)
                                .addTo(this.map);
                        })
                    })
                } else{
                    console.log("There was an error in the request??")
                }
            })
            .catch(error => {
                    console.log("error")
                }
            )
    }

    disconnect() {
        this.map.remove();
    }
}