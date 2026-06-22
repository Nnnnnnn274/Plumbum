// NSBar - Compact live download/upload speed overlay
// Ported from d1y/cyanide-ios

const NSBAR_POSITION = "right"; // left, center, right
const UPDATE_INTERVAL_MS = 1000;

let lastRxBytes = 0;
let lastTxBytes = 0;

function getNetworkStats() {
    try {
        // Read network interface statistics from kernel
        const rxAddr = 0x180000030;
        const txAddr = 0x180000038;
        
        const rxBytes = remote_read(rxAddr, 8);
        const txBytes = remote_read(txAddr, 8);
        
        return { rx: rxBytes, tx: txBytes };
    } catch (e) {
        console.error("Failed to read network stats:", e);
        return { rx: 0, tx: 0 };
    }
}

function calculateSpeed(current, last, intervalSec) {
    if (last === 0) return 0;
    const diff = current - last;
    return (diff / intervalSec / 1024).toFixed(1); // KB/s
}

function updateNSBar() {
    const stats = getNetworkStats();
    const intervalSec = UPDATE_INTERVAL_MS / 1000;
    
    const rxSpeed = calculateSpeed(stats.rx, lastRxBytes, intervalSec);
    const txSpeed = calculateSpeed(stats.tx, lastTxBytes, intervalSec);
    
    lastRxBytes = stats.rx;
    lastTxBytes = stats.tx;
    
    const displayText = `↓${rxSpeed} ↑${txSpeed}`;
    
    // Position based on setting
    let xPos;
    switch (NSBAR_POSITION) {
        case "left":
            xPos = 10;
            break;
        case "center":
            xPos = 160;
            break;
        case "right":
        default:
            xPos = 310;
            break;
    }
    
    console.log("NSBar:", displayText, "at position:", NSBAR_POSITION);
    
    return displayText;
}

// Main execution
console.log("NSBar loaded");
updateNSBar();
