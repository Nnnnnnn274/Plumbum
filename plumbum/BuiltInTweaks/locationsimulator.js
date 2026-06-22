// Location Simulator - Drives CoreLocation simulation
// Credits: kolbicz for RemoteCall/CLSimulationManager prototype, ezzuldinSt for LSpoof

const LOC_SIM_CONFIG = {
    enabled: false,
    latitude: 37.7749,
    longitude: -122.4194,
    altitude: 0,
    horizontalAccuracy: 5.0,
    verticalAccuracy: 5.0
};

const CL_SIMULATOR_OFFSET = 0x180000A00;
const CL_COORD_OFFSET = 0x180000A10;

function setLocation(lat, lon) {
    try {
        LOC_SIM_CONFIG.latitude = lat;
        LOC_SIM_CONFIG.longitude = lon;
        
        // Convert to fixed-point for kernel
        const latFixed = Math.floor(lat * 1000000);
        const lonFixed = Math.floor(lon * 1000000);
        
        const coordValue = (latFixed << 32) | (lonFixed & 0xFFFFFFFF);
        remote_write(CL_COORD_OFFSET, coordValue);
        
        console.log(`Location set: ${lat}, ${lon}`);
        return true;
    } catch (e) {
        console.error("Failed to set location:", e);
        return false;
    }
}

function enableLocationSimulation() {
    try {
        LOC_SIM_CONFIG.enabled = true;
        remote_write(CL_SIMULATOR_OFFSET, 0x1);
        
        console.log("Location simulation enabled");
        console.log(`  Lat: ${LOC_SIM_CONFIG.latitude}`);
        console.log(`  Lon: ${LOC_SIM_CONFIG.longitude}`);
        console.log("WARNING: Simulated locations may violate terms of service");
        console.log("Use only where you have permission");
        
        return true;
    } catch (e) {
        console.error("Failed to enable location simulation:", e);
        return false;
    }
}

function disableLocationSimulation() {
    try {
        LOC_SIM_CONFIG.enabled = false;
        remote_write(CL_SIMULATOR_OFFSET, 0x0);
        
        console.log("Location simulation disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable location simulation:", e);
        return false;
    }
}

// Main execution - disabled by default for safety
console.log("Location Simulator loaded");
console.log("Disabled by default - enable with caution");
