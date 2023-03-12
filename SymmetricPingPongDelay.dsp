declare name "SymmetricPingPongDelay";
declare author "mogesystem";
declare version "1.0";
declare license "GPLv3";

import("stdfaust.lib");
SR = fconstant(int fSamplingFreq, <math.h>);

params = environment {
    dryMix    = hslider("[0]Dry Mix", 1.0, 0.0, 1.0, 0.001);
    wetMix    = hslider("[1]Wet Mix", 1.0, 0.0, 1.0, 0.001);
    delaytime = hslider("[2]Time", 0.5, 0.0, 1.0, 0.001);
    repeat    = hslider("[3]Repeat", 8, 2, 32, 0.1);
    swapWetLR = checkbox("[4]Swap Wet L/R");
};

wet(x, time, feedback) = loop ~ *(feedback)
with {
    loop(d) = delayFF(time, x) + 0.999 * delayFB(d);
    delayFF(time) = de.fdelay(1 << 16, SR * time);
    delayFB = de.fdelay(1 << 16, SR * params.delaytime * 2);
};

pingpong(sigL, sigR) = params.dryMix*sigL + params.wetMix*wetL, params.dryMix*sigR + params.wetMix*wetR
with {
    center = (sigL + sigR) * 0.5;
    wetL = wet(center, params.delaytime * select2(params.swapWetLR, 1, 2), feedback);
    wetR = wet(center, params.delaytime * select2(params.swapWetLR, 2, 1), feedback);
    feedback = 0.001 ^ (1.0 / (params.repeat / 2));
};

process = pingpong;
