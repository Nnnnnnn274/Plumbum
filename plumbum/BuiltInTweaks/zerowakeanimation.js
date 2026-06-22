// Zero Wake Animation - Snaps display on instantly when waking
// Ported from kolbicz/DarkSword-Tweaks

const WAKE_ANIMATION_DURATION_OFFSET = 0x180000320;

function setZeroWakeAnimation() {
    try {
        // Set wake animation duration to 0
        remote_write(WAKE_ANIMATION_DURATION_OFFSET, 0);
        
        console.log("Zero Wake Animation enabled");
        return true;
    } catch (e) {
        console.error("Failed to set Zero Wake Animation:", e);
        return false;
    }
}

function restoreWakeAnimation() {
    try {
        // Restore default wake animation duration (typically 0.3 seconds = ~300ms)
        const defaultDuration = 0x12C00000; // Fixed-point representation
        remote_write(WAKE_ANIMATION_DURATION_OFFSET, defaultDuration);
        
        console.log("Wake Animation restored");
        return true;
    } catch (e) {
        console.error("Failed to restore Wake Animation:", e);
        return false;
    }
}

// Main execution - enable zero wake by default
console.log("Zero Wake Animation loaded");
setZeroWakeAnimation();
