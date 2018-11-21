# Cocoa poll events test

Simple script measuring the latency of the `nextEventMatching` call
for a custom game loop.

```c
while (num_ticks < max_ticks) {

    // poll events
    @autoreleasepool {
        for (;;) {
            uint64_t t = mach_absolute_time();
            // equiv to untilDate:[NSDate distantPast]
            NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES]; 
            t = mach_absolute_time() - t;
            ticks[num_ticks] = (Tick) { 
                .mach_time_diff = t, 
                .event = (event) ? (uint64_t) [event type] : (uint64_t) 0
            };
            ++num_ticks;
            if (event) {
                [NSApp sendEvent:event];
            } else {
                break;
            }
        }
    }

    // simulate update and vsynced render with nanosleep
    static struct timespec sleep_time = { .tv_sec=0, .tv_nsec=16000000 };
    struct timespec actual_sleep_time = { 0 };
    nanosleep(&sleep_time,&actual_sleep_time);    
}
```
