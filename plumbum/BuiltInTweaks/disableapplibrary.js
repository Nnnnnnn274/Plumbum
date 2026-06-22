// Disable App Library - Removes the App Library page
// Ported from kolbicz/DarkSword-Tweaks

const APPLIBRARY_FLAG_OFFSET = 0x180000300;

function disableAppLibrary() {
    try {
        const currentValue = remote_read(APPLIBRARY_FLAG_OFFSET, 4);
        const newValue = currentValue | 0x1; // Set bit 0 to disable
        remote_write(APPLIBRARY_FLAG_OFFSET, newValue);
        
        console.log("App Library disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable App Library:", e);
        return false;
    }
}

function enableAppLibrary() {
    try {
        const currentValue = remote_read(APPLIBRARY_FLAG_OFFSET, 4);
        const newValue = currentValue & ~0x1; // Clear bit 0 to enable
        remote_write(APPLIBRARY_FLAG_OFFSET, newValue);
        
        console.log("App Library enabled");
        return true;
    } catch (e) {
        console.error("Failed to enable App Library:", e);
        return false;
    }
}

// Main execution - disable by default
console.log("Disable App Library loaded");
disableAppLibrary();
