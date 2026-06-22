// Signal Readouts - Replaces signal glyphs with numeric readouts
// RSRP dBm on cellular, bar count on WiFi

const SIGNAL_CONFIG = {
    enabled: true,
    showRSRP: true,
    showBarCount: true
};

const SIGNAL_OVERRIDE_OFFSET = 0x180000D00;
const CELLULAR_RSRP_OFFSET = 0x180000D10;
const WIFI_BARS_OFFSET = 0x180000D18;

function getCellularRSRP() {
    try {
        const rsrp = remote_read(CELLULAR_RSRP_OFFSET, 4);
        // Convert to dBm
        const rsrpDbm = rsrp / 10.0;
        return rsrpDbm.toFixed(1);
    } catch (e) {
        console.error("Failed to read RSRP:", e);
        return "??";
    }
}

function getWiFiBars() {
    try {
        const bars = remote_read(WIFI_BARS_OFFSET, 4);
        return bars;
    } catch (e) {
        console.error("Failed to read WiFi bars:", e);
        return 0;
    }
}

function enableSignalReadouts() {
    try {
        SIGNAL_CONFIG.enabled = true;
        
        // Enable signal override
        const overrideFlags = (SIGNAL_CONFIG.enabled ? 0x1 : 0x0) |
                            (SIGNAL_CONFIG.showRSRP ? 0x2 : 0x0) |
                            (SIGNAL_CONFIG.showBarCount ? 0x4 : 0x0);
        remote_write(SIGNAL_OVERRIDE_OFFSET, overrideFlags);
        
        console.log("Signal Readouts enabled");
        console.log(`  RSRP: ${SIGNAL_CONFIG.showRSRP}`);
        console.log(`  Bar count: ${SIGNAL_CONFIG.showBarCount}`);
        
        return true;
    } catch (e) {
        console.error("Failed to enable Signal Readouts:", e);
        return false;
    }
}

function disableSignalReadouts() {
    try {
        SIGNAL_CONFIG.enabled = false;
        remote_write(SIGNAL_OVERRIDE_OFFSET, 0);
        
        console.log("Signal Readouts disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable Signal Readouts:", e);
        return false;
    }
}

function updateSignalDisplay() {
    if (!SIGNAL_CONFIG.enabled) return;
    
    let displayText = "";
    
    if (SIGNAL_CONFIG.showRSRP) {
        displayText += `${getCellularRSRP()}dBm `;
    }
    
    if (SIGNAL_CONFIG.showBarCount) {
        displayText += `${getWiFiBars()} bars`;
    }
    
    console.log("Signal:", displayText);
}

// Main execution
console.log("Signal Readouts loaded");
enableSignalReadouts();
updateSignalDisplay();
