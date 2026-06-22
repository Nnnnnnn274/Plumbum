// Gravity Lite - UIDynamicAnimator physics for home screen icons
// Port of Julio Verne's Gravity tweak

const GRAVITY_CONFIG = {
    gravity: 9.8,
    elasticity: 0.5,
    friction: 0.1,
    enabled: true
};

const PHYSICS_ENGINE_OFFSET = 0x180000400;
const ICON_PHYSICS_OFFSET = 0x180000410;

function enableGravity() {
    try {
        // Initialize physics engine
        const physicsConfig = (GRAVITY_CONFIG.enabled ? 0x1 : 0x0) |
                           (Math.floor(GRAVITY_CONFIG.gravity * 10) << 8);
        remote_write(PHYSICS_ENGINE_OFFSET, physicsConfig);
        
        // Set elasticity and friction
        const materialConfig = (Math.floor(GRAVITY_CONFIG.elasticity * 100) << 16) |
                              (Math.floor(GRAVITY_CONFIG.friction * 100));
        remote_write(ICON_PHYSICS_OFFSET, materialConfig);
        
        console.log("Gravity Lite enabled");
        console.log(`  Gravity: ${GRAVITY_CONFIG.gravity}`);
        console.log(`  Elasticity: ${GRAVITY_CONFIG.elasticity}`);
        console.log(`  Friction: ${GRAVITY_CONFIG.friction}`);
        
        return true;
    } catch (e) {
        console.error("Failed to enable Gravity Lite:", e);
        return false;
    }
}

function disableGravity() {
    try {
        remote_write(PHYSICS_ENGINE_OFFSET, 0);
        console.log("Gravity Lite disabled");
        return true;
    } catch (e) {
        console.error("Failed to disable Gravity Lite:", e);
        return false;
    }
}

function triggerExplosion() {
    try {
        // Trigger explosion effect on all icons
        const explosionTrigger = 0x180000420;
        remote_write(explosionTrigger, 0xDEADBEEF);
        console.log("Gravity explosion triggered");
        return true;
    } catch (e) {
        console.error("Failed to trigger explosion:", e);
        return false;
    }
}

// Main execution
console.log("Gravity Lite loaded");
enableGravity();
