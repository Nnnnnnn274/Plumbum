// Double-Tap to Lock - Lock device with wallpaper double-tap
// Ported from kolbicz/DarkSword-Tweaks

const GESTURE_HANDLER_OFFSET = 0x180000340;
const DOUBLE_TAP_FLAG_OFFSET = 0x180000348;

function enableDoubleTapLock() {
    try {
        // Enable double-tap gesture recognition on wallpaper
        const gestureConfig = remote_read(GESTURE_HANDLER_OFFSET, 4);
        const newConfig = gestureConfig | 0x4; // Enable double-tap
        remote_write(GESTURE_HANDLER_OFFSET, newConfig);
        
        // Set the double-tap action to lock
        remote_write(DOUBLE_TAP_FLAG_OFFSET, 1); // 1 = lock action
        
        console.log("Double-Tap to Lock enabled");
        return true;
    } catch (e) {
        console.error("Failed to enable Double-Tap to Lock:", e);
        return false;
    }
}

function disableDoubleTapLock() {
    try {
        const gestureConfig = remote_read(GESTURE_HANDLER_OFFSET, 4);
        const newConfig = gestureConfig & ~0x4; // Disable double-tap
        remote_write(GESTURE_HANDLER_OFFSET, newConfig);
        
        console.log("Double-Tap to Lock disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable Double-Tap to Lock:", e);
        return false;
    }
}

// Main execution - enable by default
console.log("Double-Tap to Lock loaded");
enableDoubleTapLock();
