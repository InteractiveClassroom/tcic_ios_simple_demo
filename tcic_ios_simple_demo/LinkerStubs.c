#include <stddef.h>

// These symbols are referenced by some prebuilt vendor frameworks shipped inside `tcic_ios`.
// In Xcode 15.2 toolchain, `swiftXPC` is not available for iOS/iOS Simulator, so those
// frameworks end up emitting `__swift_FORCE_LOAD_$_swiftXPC` without a provider.
//
// For demo purposes, we provide a no-op implementation to satisfy the linker.
// NOTE: `$` is not a valid C identifier character, so we must use an asm label.
void tcic_force_load_swiftXPC(void) __asm__("__swift_FORCE_LOAD_$_swiftXPC");
void tcic_force_load_swiftXPC(void) {}

// The following C symbols are referenced from `tencent_rtc_sdk` (e.g. SymbolDummy.o).
// They appear to be optional feature hooks; providing stubs allows the demo to link/run.
void v2tx_live_pusher_set_system_audio_loopback_volume(void) {}
void v2tx_live_pusher_start_system_audio_loopback(void) {}
void v2tx_live_pusher_stop_system_audio_loopback(void) {}

