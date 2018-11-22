#import <Cocoa/Cocoa.h>
#import <mach/mach_time.h> // for mach_absolute_time
#import <pthread.h>

void *cocoa_app_high_priority(void *data)
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

			// simulate update and vsynced render with nanosleep
			static struct timespec sleep_time = { .tv_sec=0, .tv_nsec=16000000 };
			struct timespec actual_sleep_time = { 0 };
			nanosleep(&sleep_time,&actual_sleep_time);	
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

pthread_t launch()
{
	// opt out of regular quality of service
	// set priority 45
	// https://developer.apple.com/videos/play/wwdc2018/612/
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	pthread_attr_setschedpolicy(&attr, SCHED_RR); // Opt out of Quality of Service
	struct sched_param param = {.sched_priority = 45}; // Configure priority 45
	pthread_attr_setschedparam(&attr, &param); // Set priority

	pthread_t posixThreadID;
	pthread_create(&posixThreadID, &attr, &cocoa_app_high_priority, pthread_self());
	pthread_attr_destroy(&attr); 

	return posixThreadID;

// 	// Create the thread using POSIX routines.
// 	pthread_attr_t  attr;
// 	pthread_t       posixThreadID;
// 	int             returnVal;
// 
// 	returnVal = pthread_attr_init(&attr);
// 	assert(!returnVal);
// 	returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
// 	assert(!returnVal);
// 
// 	int     threadError = pthread_create(&posixThreadID, &attr, &PosixThreadMainRoutine, NULL);
// 
// 	returnVal = pthread_attr_destroy(&attr);
// 	assert(!returnVal);
// 	if (threadError != 0)
// 	{
// 		// Report an error.
// 	}
}

int main()
{
	pthread_t cocoa_app_thread = launch();
	pthread_join(cocoa_app_thread, 0);
}
