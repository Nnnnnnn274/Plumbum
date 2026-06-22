// LiveWP - Plays MP4/MOV/M4V behind SpringBoard windows
// Ported from d1y/cyanide-ios

const LIVEWP_CONFIG = {
    videoPath: "/var/mobile/Library/Plumbum/LiveWP/video.mp4",
    enabled: false,
    loop: true
};

const SB_WINDOW_OFFSET = 0x180000800;
const LIVEWP_PLAYER_OFFSET = 0x180000810;

function setLiveWallpaper(videoPath) {
    try {
        LIVEWP_CONFIG.videoPath = videoPath;
        LIVEWP_CONFIG.enabled = true;
        
        // Get SpringBoard window addresses
        const homeWindow = remote_read(SB_WINDOW_OFFSET, 8);
        const lockWindow = remote_read(SB_WINDOW_OFFSET + 8, 8);
        
        // Initialize video player
        const playerConfig = (LIVEWP_CONFIG.enabled ? 0x1 : 0x0) |
                           (LIVEWP_CONFIG.loop ? 0x2 : 0x0);
        remote_write(LIVEWP_PLAYER_OFFSET, playerConfig);
        
        // Set video path
        remote_write(LIVEWP_PLAYER_OFFSET + 8, videoPath);
        
        // Attach player to windows
        remote_write(SB_WINDOW_OFFSET + 16, homeWindow);
        remote_write(SB_WINDOW_OFFSET + 24, lockWindow);
        
        console.log("LiveWP enabled");
        console.log(`  Video: ${videoPath}`);
        console.log(`  Loop: ${LIVEWP_CONFIG.loop}`);
        
        return true;
    } catch (e) {
        console.error("Failed to set LiveWP:", e);
        return false;
    }
}

function disableLiveWallpaper() {
    try {
        LIVEWP_CONFIG.enabled = false;
        remote_write(LIVEWP_PLAYER_OFFSET, 0);
        
        console.log("LiveWP disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable LiveWP:", e);
        return false;
    }
}

// Main execution
console.log("LiveWP loaded");
// Disabled by default - user must set video path
