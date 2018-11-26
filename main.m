#import <Cocoa/Cocoa.h>
#import <mach/mach_time.h> // for mach_absolute_time

int main()
{
	@autoreleasepool {

		[NSApplication sharedApplication];
		[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
		[NSApp setPresentationOptions:NSApplicationPresentationDefault];
		[NSApp activateIgnoringOtherApps:YES];

		/*
		id menubar = [[NSMenu new] autorelease];
		id appMenuItem = [[NSMenuItem new] autorelease];
		[menubar addItem:appMenuItem];
		[NSApp setMainMenu:menubar];
		id appMenu = [[NSMenu new] autorelease];
		id appName = [[NSProcessInfo processInfo] processName];
		id quitTitle = [@"Quit " stringByAppendingString:appName];
		id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle
		action:@selector(terminate:) keyEquivalent:@"q"] autorelease];
		[appMenu addItem:quitMenuItem];
		[appMenuItem setSubmenu:appMenu];
		*/
		id window = [NSWindow alloc];
		[window initWithContentRect:NSMakeRect(0, 0, 640, 640)
				  styleMask:NSWindowStyleMaskTitled
				    backing:NSBackingStoreBuffered defer:NO];
		[window autorelease];
		[window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
		// [window setTitle:appName];
		[window makeKeyAndOrderFront:nil];

		typedef struct {
			uint64_t mach_time_diff;
			uint64_t event;
		} Tick;

		int max_ticks = 1000; // capture first 1000 events from nextEventMatchingMask
		int num_ticks = 0;
		Tick *ticks = malloc(sizeof(Tick) * 5000);

		// keep pumping events using nextEventMatchingMask 
		// and measuring its latency in a sleep-vsynced-simulated way
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
			usleep(15000); // microseconds sleep
		}

		// dump events and their time differences into
		{
			mach_timebase_info_data_t timebase;
			mach_timebase_info(&timebase);
			FILE *f = fopen("ticks","w");
			fprintf(f,"n|t|e\n");
			for (int i=0;i<num_ticks;++i) {
				double nanoseconds = ticks[i].mach_time_diff * ((double) timebase.numer / timebase.denom);
				fprintf(f,"%d|%.0f|%d\n", i, nanoseconds, (int) ticks[i].event);
			}
			fclose(f);
		}

	} // autorelease pool

	return 0;
}
