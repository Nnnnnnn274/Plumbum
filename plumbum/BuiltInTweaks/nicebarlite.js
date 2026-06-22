// NiceBar Lite - Configurable status-bar-adjacent labels
// Ported from d1y/cyanide-ios

const CONFIG = {
    showCustomText: true,
    customText: "Plumbum",
    showDateTime: true,
    dateFormat: "HH:mm",
    showBattery: true,
    showMemory: true,
    showTraffic: true,
    showUptime: false,
    showIPAddress: false,
    showDisk: false,
    showThermal: true
};

function getDateTime() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
}

function getBatteryLevel() {
    try {
        const batteryAddr = 0x180000040;
        const level = remote_read(batteryAddr, 4);
        return `${level}%`;
    } catch (e) {
        console.error("Failed to read battery:", e);
        return "??%";
    }
}

function getMemoryUsage() {
    try {
        const memAddr = 0x180000010;
        const memInfo = remote_read(memAddr, 8);
        const used = (memInfo & 0xFFFFFFFF);
        const total = (memInfo >> 32);
        return `${((used / total) * 100).toFixed(0)}%`;
    } catch (e) {
        console.error("Failed to read memory:", e);
        return "??%";
    }
}

function getThermalState() {
    try {
        const thermalAddr = 0x180000000;
        const level = remote_read(thermalAddr, 4);
        return level;
    } catch (e) {
        console.error("Failed to read thermal:", e);
        return 0;
    }
}

function updateNiceBar() {
    let labels = [];
    
    if (CONFIG.showCustomText) {
        labels.push(CONFIG.customText);
    }
    
    if (CONFIG.showDateTime) {
        labels.push(getDateTime());
    }
    
    if (CONFIG.showBattery) {
        labels.push(getBatteryLevel());
    }
    
    if (CONFIG.showMemory) {
        labels.push(getMemoryUsage());
    }
    
    if (CONFIG.showThermal) {
        labels.push(`${getThermalState()}°`);
    }
    
    const displayText = labels.join(" | ");
    console.log("NiceBar Lite:", displayText);
    
    return displayText;
}

// Main execution
console.log("NiceBar Lite loaded");
updateNiceBar();
