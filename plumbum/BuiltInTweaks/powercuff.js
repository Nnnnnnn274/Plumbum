// Powercuff - CPU/GPU underclocking through thermalmonitord pressure simulation
// Port of rpetrich/Powercuff

const PRESSURE_LEVELS = {
    off: 0,
    nominal: 1,
    light: 2,
    moderate: 3,
    heavy: 4
};

let currentPressure = PRESSURE_LEVELS.off;

const THERMALMONITOR_OFFSET = 0x180000200;
const CPU_LIMIT_OFFSET = 0x180000210;
const GPU_LIMIT_OFFSET = 0x180000218;

function setPressureLevel(level) {
    try {
        currentPressure = level;
        
        // Write pressure level to thermalmonitord simulation
        remote_write(THERMALMONITOR_OFFSET, level);
        
        // Set CPU and GPU limits based on pressure
        let cpuLimit, gpuLimit;
        
        switch (level) {
            case PRESSURE_LEVELS.off:
                cpuLimit = 0xFFFFFFFF; // No limit
                gpuLimit = 0xFFFFFFFF;
                break;
            case PRESSURE_LEVELS.nominal:
                cpuLimit = 0xFFFF0000; // ~75%
                gpuLimit = 0xFFFF0000;
                break;
            case PRESSURE_LEVELS.light:
                cpuLimit = 0xCCCC0000; // ~60%
                gpuLimit = 0xCCCC0000;
                break;
            case PRESSURE_LEVELS.moderate:
                cpuLimit = 0x99990000; // ~45%
                gpuLimit = 0x99990000;
                break;
            case PRESSURE_LEVELS.heavy:
                cpuLimit = 0x66660000; // ~30%
                gpuLimit = 0x66660000;
                break;
        }
        
        remote_write(CPU_LIMIT_OFFSET, cpuLimit);
        remote_write(GPU_LIMIT_OFFSET, gpuLimit);
        
        console.log("Powercuff pressure level set:", Object.keys(PRESSURE_LEVELS)[level]);
        
        return true;
    } catch (e) {
        console.error("Failed to set Powercuff pressure:", e);
        return false;
    }
}

// Default to moderate pressure for battery saving
console.log("Powercuff loaded");
setPressureLevel(PRESSURE_LEVELS.moderate);
