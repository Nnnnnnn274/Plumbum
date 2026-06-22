// Home Layout Extras - Extra padding and per-icon scale
// Stacks on top of SBCustomizer

const CONFIG = {
    homePaddingTop: 10,
    homePaddingBottom: 10,
    homePaddingLeft: 5,
    homePaddingRight: 5,
    dockPaddingTop: 5,
    dockPaddingBottom: 5,
    homeIconScale: 1.0,
    dockIconScale: 1.0
};

const PADDING_OFFSET = 0x180000130;
const ICON_SCALE_OFFSET = 0x180000140;

function applyHomeLayoutExtras() {
    try {
        // Write padding values
        const paddingValue = (CONFIG.homePaddingTop & 0xFF) << 24 |
                           (CONFIG.homePaddingBottom & 0xFF) << 16 |
                           (CONFIG.homePaddingLeft & 0xFF) << 8 |
                           (CONFIG.homePaddingRight & 0xFF);
        remote_write(PADDING_OFFSET, paddingValue);
        
        const dockPaddingValue = (CONFIG.dockPaddingTop & 0xFF) << 8 |
                                (CONFIG.dockPaddingBottom & 0xFF);
        remote_write(PADDING_OFFSET + 4, dockPaddingValue);
        
        // Write icon scale values (as fixed-point 16.16)
        const homeScale = Math.floor(CONFIG.homeIconScale * 65536);
        const dockScale = Math.floor(CONFIG.dockIconScale * 65536);
        const scaleValue = (homeScale << 32) | dockScale;
        remote_write(ICON_SCALE_OFFSET, scaleValue);
        
        console.log("Home Layout Extras applied:");
        console.log(`  Home padding: ${CONFIG.homePaddingTop}/${CONFIG.homePaddingBottom}/${CONFIG.homePaddingLeft}/${CONFIG.homePaddingRight}`);
        console.log(`  Dock padding: ${CONFIG.dockPaddingTop}/${CONFIG.dockPaddingBottom}`);
        console.log(`  Home scale: ${CONFIG.homeIconScale}x`);
        console.log(`  Dock scale: ${CONFIG.dockIconScale}x`);
        
        return true;
    } catch (e) {
        console.error("Failed to apply Home Layout Extras:", e);
        return false;
    }
}

// Main execution
console.log("Home Layout Extras loaded");
applyHomeLayoutExtras();
