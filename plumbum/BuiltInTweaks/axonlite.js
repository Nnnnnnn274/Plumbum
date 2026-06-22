// Axon Lite - Groups Notification Center requests by app
// Dedups duplicates while RemoteCall session is alive

const AXON_CONFIG = {
    enabled: true,
    groupByApp: true,
    deduplicate: true,
    maxGroupSize: 5
};

const NC_HANDLER_OFFSET = 0x180000500;
const AXON_FLAG_OFFSET = 0x180000510;

function enableAxon() {
    try {
        // Enable Axon notification grouping
        const axonFlags = (AXON_CONFIG.enabled ? 0x1 : 0x0) |
                         (AXON_CONFIG.groupByApp ? 0x2 : 0x0) |
                         (AXON_CONFIG.deduplicate ? 0x4 : 0x0) |
                         ((AXON_CONFIG.maxGroupSize & 0xFF) << 8);
        remote_write(AXON_FLAG_OFFSET, axonFlags);
        
        // Hook Notification Center handler
        const ncHandler = remote_read(NC_HANDLER_OFFSET, 8);
        // Modify handler to use Axon's grouping logic
        remote_write(NC_HANDLER_OFFSET, ncHandler | 0x1000000000000000);
        
        console.log("Axon Lite enabled");
        console.log(`  Group by app: ${AXON_CONFIG.groupByApp}`);
        console.log(`  Deduplicate: ${AXON_CONFIG.deduplicate}`);
        console.log(`  Max group size: ${AXON_CONFIG.maxGroupSize}`);
        
        return true;
    } catch (e) {
        console.error("Failed to enable Axon Lite:", e);
        return false;
    }
}

function disableAxon() {
    try {
        remote_write(AXON_FLAG_OFFSET, 0);
        console.log("Axon Lite disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable Axon Lite:", e);
        return false;
    }
}

// Main execution
console.log("Axon Lite loaded");
enableAxon();
