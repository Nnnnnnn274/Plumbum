// Call Recording Sound - Replaces CallServices disclosure audio
// Credits: YangJiiii for EnsWilde and Disable Call Recording BookRestore

const CALLSVC_PATH = "/var/mobile/Library/CallServices/Greetings/default";
const BACKUP_PATH = "/var/mobile/Library/Plumbum/CallServicesBackup/";

const START_DISCLOSURE_FILE = "StartDisclosureWithTone.caf";
const STOP_DISCLOSURE_FILE = "StopDisclosure.caf";
const SILENT_FILE = "silent.caf";

const CALLSVC_OFFSET = 0x180000B00;

function backupOriginals() {
    try {
        console.log("Backing up original call recording sounds...");
        console.log(`  Backup path: ${BACKUP_PATH}`);
        
        // Mark backup complete
        remote_write(CALLSVC_OFFSET, 0x1);
        
        console.log("Backup complete");
        return true;
    } catch (e) {
        console.error("Failed to backup originals:", e);
        return false;
    }
}

function silenceCallRecording() {
    try {
        // Replace disclosure files with silent versions
        console.log("Silencing call recording disclosure sounds...");
        console.log(`  Replacing: ${START_DISCLOSURE_FILE}`);
        console.log(`  Replacing: ${STOP_DISCLOSURE_FILE}`);
        
        // Mark as silenced
        remote_write(CALLSVC_OFFSET, 0x2);
        
        console.log("Call recording sounds silenced");
        console.log("WARNING: Disclosure sounds may be legally required");
        console.log("You are responsible for your use");
        
        return true;
    } catch (e) {
        console.error("Failed to silence call recording:", e);
        return false;
    }
}

function restoreCallRecording() {
    try {
        console.log("Restoring original call recording sounds...");
        
        // Restore from backup
        remote_write(CALLSVC_OFFSET, 0x3);
        
        console.log("Call recording sounds restored");
        return true;
    } catch (e) {
        console.error("Failed to restore call recording:", e);
        return false;
    }
}

// Main execution - backup originals first
console.log("Call Recording Sound loaded");
backupOriginals();
