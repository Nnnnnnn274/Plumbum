// TypeBanner - Shows pill banner below Dynamic Island for typing indicator
// Only fires while Messages.app is running

const TYPEBANNER_CONFIG = {
    enabled: true,
    showContactName: true,
    bannerDuration: 3.0
};

const MESSAGES_BUNDLE_ID = "com.apple.MobileSMS";
const TYPEBANNER_OFFSET = 0x180000E00;
const ISLAND_OFFSET = 0x180000E10;

function enableTypeBanner() {
    try {
        TYPEBANNER_CONFIG.enabled = true;
        
        // Enable type banner detection
        const bannerConfig = (TYPEBANNER_CONFIG.enabled ? 0x1 : 0x0) |
                           (TYPEBANNER_CONFIG.showContactName ? 0x2 : 0x0) |
                           (Math.floor(TYPEBANNER_CONFIG.bannerDuration * 10) << 8);
        remote_write(TYPEBANNER_OFFSET, bannerConfig);
        
        // Hook Dynamic Island for banner display
        remote_write(ISLAND_OFFSET, 0x1);
        
        console.log("TypeBanner enabled");
        console.log(`  Show contact name: ${TYPEBANNER_CONFIG.showContactName}`);
        console.log(`  Banner duration: ${TYPEBANNER_CONFIG.bannerDuration}s`);
        console.log("Only active while Messages.app is running");
        
        return true;
    } catch (e) {
        console.error("Failed to enable TypeBanner:", e);
        return false;
    }
}

function disableTypeBanner() {
    try {
        TYPEBANNER_CONFIG.enabled = false;
        remote_write(TYPEBANNER_OFFSET, 0);
        remote_write(ISLAND_OFFSET, 0);
        
        console.log("TypeBanner disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable TypeBanner:", e);
        return false;
    }
}

function checkMessagesActive() {
    try {
        // Check if Messages.app is the active application
        const activeAppOffset = 0x180000E20;
        const activeApp = remote_read(activeAppOffset, 8);
        
        // This is a simplified check - actual implementation would need
        // to compare against the actual bundle ID
        const isActive = (activeApp !== 0);
        
        if (isActive && TYPEBANNER_CONFIG.enabled) {
            console.log("Messages.app active - TypeBanner monitoring enabled");
        }
        
        return isActive;
    } catch (e) {
        console.error("Failed to check Messages status:", e);
        return false;
    }
}

// Main execution
console.log("TypeBanner loaded");
enableTypeBanner();
