// Watch Pairing Override - Edits watchOS pairing range
// Persists across reboots; respring before pairing

const WATCH_PAIRING_OFFSET = 0x180000900;
const PAIRING_RANGE_DEFAULT = 0x00000000FFFFFFFF;
const PAIRING_RANGE_UNLIMITED = 0xFFFFFFFFFFFFFFFF;

function setUnlimitedPairing() {
    try {
        // Set pairing range to unlimited
        remote_write(WATCH_PAIRING_OFFSET, PAIRING_RANGE_UNLIMITED);
        
        console.log("Watch Pairing Override enabled");
        console.log("Pairing range set to unlimited");
        console.log("Respring before pairing");
        
        return true;
    } catch (e) {
        console.error("Failed to set unlimited pairing:", e);
        return false;
    }
}

function restoreDefaultPairing() {
    try {
        remote_write(WATCH_PAIRING_OFFSET, PAIRING_RANGE_DEFAULT);
        
        console.log("Watch pairing range restored to default");
        return true;
    } catch (e) {
        console.error("Failed to restore pairing range:", e);
        return false;
    }
}

function getCurrentPairingRange() {
    try {
        const range = remote_read(WATCH_PAIRING_OFFSET, 8);
        console.log(`Current pairing range: 0x${range.toString(16)}`);
        return range;
    } catch (e) {
        console.error("Failed to read pairing range:", e);
        return 0;
    }
}

// Main execution - enable unlimited pairing by default
console.log("Watch Pairing Override loaded");
setUnlimitedPairing();
