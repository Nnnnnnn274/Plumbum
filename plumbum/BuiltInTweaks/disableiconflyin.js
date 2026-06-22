// Disable Icon Fly-In - Skips the spring-in animation
// Ported from kolbicz/DarkSword-Tweaks

const ICON_ANIMATION_FLAG_OFFSET = 0x180000310;

function disableIconFlyIn() {
    try {
        const currentValue = remote_read(ICON_ANIMATION_FLAG_OFFSET, 4);
        const newValue = currentValue | 0x2; // Set bit 1 to disable fly-in
        remote_write(ICON_ANIMATION_FLAG_OFFSET, newValue);
        
        console.log("Icon Fly-In disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable Icon Fly-In:", e);
        return false;
    }
}

function enableIconFlyIn() {
    try {
        const currentValue = remote_read(ICON_ANIMATION_FLAG_OFFSET, 4);
        const newValue = currentValue & ~0x2; // Clear bit 1 to enable
        remote_write(ICON_ANIMATION_FLAG_OFFSET, newValue);
        
        console.log("Icon Fly-In enabled");
        return true;
    } catch (e) {
        console.error("Failed to enable Icon Fly-In:", e);
        return false;
    }
}

// Main execution - disable by default
console.log("Disable Icon Fly-In loaded");
disableIconFlyIn();
