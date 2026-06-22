// SBCustomizer - Dock icon count, home-screen columns/rows, hidden icon labels
// Native port of lightsaber sbcustomizer payload

const CONFIG = {
    dockIconCount: 4,
    homeColumns: 4,
    homeRows: 6,
    hideIconLabels: false
};

// SpringBoard layout structure offsets
const SB_LAYOUT_OFFSET = 0x180000100;
const DOCK_CONFIG_OFFSET = 0x180000110;
const ICON_LABELS_OFFSET = 0x180000120;

function applySBCustomizer() {
    try {
        // Modify dock icon count
        const dockConfig = remote_read(DOCK_CONFIG_OFFSET, 4);
        const newDockConfig = (dockConfig & 0xFFFF0000) | (CONFIG.dockIconCount & 0xFFFF);
        remote_write(DOCK_CONFIG_OFFSET, newDockConfig);
        
        // Modify home grid columns and rows
        const layoutConfig = remote_read(SB_LAYOUT_OFFSET, 8);
        const newLayoutConfig = (layoutConfig & 0xFFFFFFFF00000000) | 
                               ((CONFIG.homeColumns & 0xFF) << 16) | 
                               (CONFIG.homeRows & 0xFF);
        remote_write(SB_LAYOUT_OFFSET, newLayoutConfig);
        
        // Hide/show icon labels
        const labelConfig = remote_read(ICON_LABELS_OFFSET, 4);
        const newLabelConfig = CONFIG.hideIconLabels ? (labelConfig | 0x1) : (labelConfig & ~0x1);
        remote_write(ICON_LABELS_OFFSET, newLabelConfig);
        
        console.log("SBCustomizer applied:");
        console.log(`  Dock icons: ${CONFIG.dockIconCount}`);
        console.log(`  Grid: ${CONFIG.homeColumns}x${CONFIG.homeRows}`);
        console.log(`  Hide labels: ${CONFIG.hideIconLabels}`);
        
        return true;
    } catch (e) {
        console.error("Failed to apply SBCustomizer:", e);
        return false;
    }
}

// Main execution
console.log("SBCustomizer loaded");
applySBCustomizer();
