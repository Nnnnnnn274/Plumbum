// Zero Backlight Fade - Instant lock/unlock backlight
// Ported from kolbicz/DarkSword-Tweaks

const BACKLIGHT_FADE_DURATION_OFFSET = 0x180000330;

function setZeroBacklightFade() {
    try {
        // Set backlight fade duration to 0
        remote_write(BACKLIGHT_FADE_DURATION_OFFSET, 0);
        
        console.log("Zero Backlight Fade enabled");
        return true;
    } catch (e) {
        console.error("Failed to set Zero Backlight Fade:", e);
        return false;
    }
}

function restoreBacklightFade() {
    try {
        // Restore default backlight fade duration (typically 0.5 seconds)
        const defaultDuration = 0x20000000; // Fixed-point representation
        remote_write(BACKLIGHT_FADE_DURATION_OFFSET, defaultDuration);
        
        console.log("Backlight Fade restored");
        return true;
    } catch (e) {
        console.error("Failed to restore Backlight Fade:", e);
        return false;
    }
}

// Main execution - enable zero fade by default
console.log("Zero Backlight Fade loaded");
setZeroBacklightFade();
