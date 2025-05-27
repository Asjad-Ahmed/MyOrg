// mapComponent.js
import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LEAFLET from '@salesforce/resourceUrl/LeefLet'; // Replace 'Leaflet' with the actual name of your static resource

export default class MapComponent extends LightningElement {
    connectedCallback() {
        Promise.all([
            loadStyle(this, LEAFLET + '/leaflet.css'),
            loadScript(this, LEAFLET + '/leaflet.js')
        ])
        .then(() => {
            this.initializeMap();
        })
        .catch(error => {
            console.error('Error loading Leaflet library', error);
        });
    }

    initializeMap() {
        const mapContainer = this.template.querySelector('.map-container');
        const map = L.map(mapContainer).setView([51.505, -0.09], 13); // Set initial coordinates and zoom level
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map); // Add OpenStreetMap layer

        // Add a marker to the map
        L.marker([51.505, -0.09]).addTo(map).bindPopup('Hello, World!'); // Marker with a popup message
    }
}