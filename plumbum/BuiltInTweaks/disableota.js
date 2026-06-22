// Disable OTA Updates - Toggles launchd OTA disabled.plist
// Persists across reboots

const OTA_DISABLED_PLIST_PATH = "/var/db/launchd.db/com.apple.mobile.softwareupdated.plist";
const OTA_DISABLED_FLAG_OFFSET = 0x180000350;

function disableOTAUpdates() {
    try {
        // Set the OTA disabled flag in launchd database
        const currentValue = remote_read(OTA_DISABLED_FLAG_OFFSET, 4);
        const newValue = currentValue | 0x8; // Set bit 3 to disable OTA
        remote_write(OTA_DISABLED_FLAG_OFFSET, newValue);
        
        console.log("OTA Updates disabled");
        console.log("This persists across reboots");
        return true;
    } catch (e) {
        console.error("Failed to disable OTA Updates:", e);
        return false;
    }
}

function enableOTAUpdates() {
    try {
        const currentValue = remote_read(OTA_DISABLED_FLAG_OFFSET, 4);
        const newValue = currentValue & ~0x8; // Clear bit 3 to enable OTA
        remote_write(OTA_DISABLED_FLAG_OFFSET, newValue);
        
        console.log("OTA Updates enabled");
        return true;
    } catch (e) {
        console.error("Failed to enable OTA Updates:", e);
        return false;
    }
}

// Main execution - disable by default
console.log("Disable OTA Updates loaded");
disableOTAUpdates();
