# Cocoa Poll Events Latency Test

Simple script measuring the latency of the `nextEventMatching` call
for a custom game loop.

```c
while (num_ticks < max_ticks) {
    // poll events
    @autoreleasepool {
        for (;;) {
            uint64_t t = mach_absolute_time();
            
            NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny 
                                                untilDate:nil 
                                                   inMode:NSDefaultRunLoopMode
                                                  dequeue:YES]; // same as untilDate:[NSDate distantPast]
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
    usleep(15000); // simulate update and vsynced render: microseconds sleep
}
```


```
# event type legend
0   nil                               
1   NSEventTypeLeftMouseDown          
2   NSEventTypeLeftMouseUp            
3   NSEventTypeRightMouseDown         
4   NSEventTypeRightMouseUp           
5   NSEventTypeMouseMoved             
6   NSEventTypeLeftMouseDragged       
7   NSEventTypeRightMouseDragged      
8   NSEventTypeMouseEntered           
9   NSEventTypeMouseExited            
10  NSEventTypeKeyDown                
11  NSEventTypeKeyUp                  
12  NSEventTypeFlagsChanged           
13  NSEventTypeAppKitDefined          
14  NSEventTypeSystemDefined          
15  NSEventTypeApplicationDefined     
16  NSEventTypePeriodic               
17  NSEventTypeCursorUpdate           
22  NSEventTypeScrollWheel            
23  NSEventTypeTabletPoint            
24  NSEventTypeTabletProximity        
25  NSEventTypeOtherMouseDown         
26  NSEventTypeOtherMouseUp           
27  NSEventTypeOtherMouseDragged      
```

