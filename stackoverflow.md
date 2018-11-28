Latency of Polling Next Event if Available on MacOS

I am trying to write a simple *game loop* for MacOS. The *event polling* solution I found on libraries like GLFW, SDL, and MacOS game ports for DOOM, Quake, Handmade Hero is to use the `nextEventMatchingMask` API. I am interested in the *latency of event polling*:

    t0 = mach_absolute_time();
    NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                        untilDate:nil
                                           inMode:NSDefaultRunLoopMode
                                          dequeue:YES];
    t1 = mach_absolute_time();
    latency=t1-t0

The experiment I run ([source code](https://github.com/laurolins/cocoa_poll_events_latency)) consists of opening a Cocoa MacOS window and "randomly" generating mouse and keyboard events. The typical latency numbers I get for the first 1000 events in such experiment looks like this

[![typical latency][1]][1]

    # latency percentiles in milliseconds
    :       0%        5%       10%       15%       20%       25%       30%       35%
    : 0.033830  0.047655  0.060302  0.071263  0.073450  0.075871  0.079204  0.083330
    :      40%       45%       50%       55%       60%       65%       70%       75%
    : 0.093038  0.107813  0.134466  0.143095  0.180434  0.334789  0.448111  0.500118
    :      80%       85%       90%       95%      100%
    : 0.524535  0.583159  0.648065  0.719931 36.567810

Note that the top 25% latencies are more that half a millisecond. Even when there is no event available (zeros on the chart) we can get a latency of more than a millisecond (see zero floating around near the 600th event). To make things worse, this is the typical case I observe when my Macbook has not much going on: just a Terminal and the test program. It gets worse when more applications are running.

I wonder if there is a more efficient way to the get the next (mouse/keyboard) event if available in a MacOS application. Is there a trick I am missing that makes `nextEventMatchingMask` calls more efficient?

The source code to run this test and generate a plot like the one above can be found here: https://github.com/laurolins/cocoa_poll_events_latency

**(update)** Following an idea [Dad](https://stackoverflow.com/users/145108/dad) suggested in the comments, I ran the test without any mouse/keyboard movement. Here are the latency percentiles:

    # latency without any keyboard/mouse event in milliseconds
    :         0%          5%         10%         15%         20%         25%
    : 0.04029500  0.07617675  0.07908070  0.08556100  0.10188940  0.12956500
    :        30%         35%         40%         45%         50%         55%
    : 0.13832200  0.14023150  0.14802140  0.15003550  0.15045250  0.15088950
    :        60%         65%         70%         75%         80%         85%
    : 0.15125000  0.15162535  0.15190300  0.15235550  0.15313200  0.15972645
    :        90%         95%        100%
    : 0.16802250  0.21194335 35.93352900

The idea of waiting .15 milliseconds to find out that no event was generated does not feel right!

  [1]: https://i.stack.imgur.com/LlRU0.png

