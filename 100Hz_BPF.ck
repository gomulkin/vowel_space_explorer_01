// F0=100 Hz, F1/F2, 
// BPF, Q1=Q2=30, 
// Gain1=1/2, Gain2=1/3


// Some Physics
350 => float c; // sound speed m/sec
0.175 => float l; // throat length
c /(4*l) => float F; // resonance freq

// Basic Model
2 => int n; // choose number of formants
BPF form[n]; // formant filter array []
float freq[n]; // formant freq array []
SawOsc glot; // voice source
Gain out; // out gain control
Gain out2; // out gain control
1 => out.gain; // out volume
1 => int gn => out2.gain; // out final volume
Gain volume[n]; // formant gain array []
100 => int aug; //freq change step
1=>float m; // variable for formant gain
0=>int fn; // formant call number
5000=> int upper; // upper limit freq change

SinOsc vibrato => glot; //Adds vibrato to voice source
5.0 => vibrato.freq;
1 => vibrato.gain;
2 => glot.sync;

// Voice Pitch Correction (male/female)
if (l >= 0.16) {F/5 => glot.freq;} // adult male
else {F/2.8 => glot.freq;} // female or child

// Starting a Neutral Vowel
fun void vowelStart() {
    for (int i; i < n; i++)  {
        glot => form[i] => volume => out => out2 => dac;
        30 => form[i].Q;
        //1/Math.exp(i+1)=> m; // "spectral slope"
        1.0/(2+i) => m; // just split the gain
        m => volume[i].gain;
        (2*(i+1)-1)*F => freq[i] => form[i].freq;
        <<<"i=",i,"freq=",freq[i], m>>>;
    } 
}

fun void circle() {
    vowelStart();
        while (true){
        0.3 => out.gain;
        1::second => now;
        0 => out.gain;
        1::second => now;
    }
}

fun void dummy(){
    while(true){
        <<<"It works!!">>>;
        1::second => now;
    }
}






// KEYBOARD-functions: ************************

// |7 8 9|
// |4 + 6|
// |1 2 3|
// Press <7> ascii==55 to move sound Up-Left
// Press <8> ascii==56 to move sound Up
// Press <9> ascii==57 to move sound Up-Right
// Press <4> ascii==52 to move sound Left
// Press <6> ascii==54 to move sound Right
// Press <1> ascii==49 to move sound Down-Left
// Press <2> ascii==50 to move sound Down
// Press <3> ascii==51 to move sound Down-Right
fun void moveSound(){
    Hid hid;	// a message to convey data from Hid
    HidMsg msg;	// device number
    0=> int device;	// try to open keyboard
    if( hid.openKeyboard( device ) == false) me.exit(); // try to open keyboard
    <<<"keyboard-0:", hid.name(), "ready!">>>; // print
    while (true){   
        hid => now; 
        if (hid.recv(msg)){
            if( msg.isButtonDown()&& msg.ascii==55){
                if (freq[0] > aug){  
                    freq[0] - aug => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] + aug => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;
                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==56){
                if (freq[0] > aug){  
                    freq[0] - aug => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;
                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==57){
                if (freq[0] > aug && freq[1] > aug){  
                    freq[0] - aug => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] - aug => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==52){
                if (freq[0] == freq[0]){  
                    freq[0] => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] + aug => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==54){
                if (freq[1] >= (freq[0] + aug)){  
                    freq[0] => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] - aug => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==49){
                if (freq[0] == freq[0]){  
                    freq[0] + aug => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] + aug => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==50){
                if (freq[1] >= (freq[0] + aug)){  
                    freq[0] + aug => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }            
            if( msg.isButtonDown()&& msg.ascii==51){
                if (freq[1] >= (freq[0] + aug)){  
                    freq[0] + aug => freq[0];
                    freq[0] => form[0].freq;
                    freq[1] - aug => freq[1];
                    freq[1] => form[1].freq;
                    <<<"F1 =",freq[0],"Hz">>>;
                    <<<"F2 =",freq[1],"Hz">>>;                }
                else {
                    freq[fn] => freq[fn];
                    <<<"F1 and/or F2 =< lower limit", aug, "Hz">>>;
                }
            }
            else {      
            }            
        0.1::second => now; 
        }
    }
}

// Press <u> to rise F3 Up
// Press <d> to lower F3 Down
fun void changeF3(){
    Hid hid;	// a message to convey data from Hid
    HidMsg msg;	// device number
    0=> int device;	// try to open keyboard
    if( hid.openKeyboard( device ) == false) me.exit(); // try to open keyboard
    <<<"keyboard-1:", hid.name(), "ready!">>>; // print
    while (true){   
        hid => now;
        if (hid.recv(msg)){
            if( msg.isButtonDown()&& msg.ascii==85 && n>2){
                if (freq[2] < upper){  
                    freq[2] + aug => freq[2];
                    freq[2] => form[2].freq;
                    <<<"F3 =",freq[2],"Hz">>>;
                }
                else {
                    freq[2] => freq[2];
                    <<<"F3 >= upper limit",upper, "Hz">>>;
                }
            }
            if( msg.isButtonDown()&& msg.ascii==68 && n>2){
                if (freq[2] > aug){
                    freq[2] - aug => freq[2];
                    freq[2] => form[2].freq;
                    <<<"F3 =",freq[2],"Hz">>>;
                }
                else {
                    freq[2] => freq[2];
                    <<<"F3 =< lower limit", aug, "Hz">>>;
                }
            }
            else {
            }
        0.1::second=>now; 
        }
    }
}

// Press <p> to Print all freqs
fun void printAll(){
    Hid hid;	// a message to convey data from Hid
    HidMsg msg;	// device number
    0=> int device;	// try to open keyboard
    if( hid.openKeyboard( device ) == false) me.exit(); // try to open keyboard
    <<<"keyboard-3:", hid.name(), "ready!">>>; // print
    while (true){   
        hid => now;
        if (hid.recv(msg)){
            if( msg.isButtonDown()&& msg.ascii==80){
                for (int i; i < n; i++)  {
                    <<<"F",i+1,"=",freq[i],"Hz">>>;
                }
            }
            else {
                fn => fn;
            }
        0.1::second => now;
        }
    }
}

// Press <b> to return to Back to starting freqs
fun void backAll(){
    Hid hid;	// a message to convey data from Hid
    HidMsg msg;	// device number
    0=> int device;	// try to open keyboard
    if( hid.openKeyboard( device ) == false) me.exit(); // try to open keyboard
    <<<"keyboard-4:", hid.name(), "ready!">>>; // print
    while (true){   
        hid => now;
        if (hid.recv(msg)){
            if( msg.isButtonDown()&& msg.ascii==66){
                for (int i; i < n; i++)  {
                    (2*(i+1)-1)*F => freq[i] => form[i].freq;
                    <<<"F",i+1,"=",freq[i],"Hz">>>;
                }
            } 
            else {
                fn => fn;
            }
        0.1::second => now;
        }
    }
}

// Press <0> to mute - press again to unmute
fun void mute(){
    Hid hid;	// a message to convey data from Hid
    HidMsg msg;	// device number
    0=> int device;	// try to open keyboard
    if( hid.openKeyboard( device ) == false) me.exit(); // try to open keyboard
    <<<"keyboard-5:", hid.name(), "ready!">>>; // print
    while (true){   
        hid => now;
        if (hid.recv(msg)){
            if( msg.isButtonDown()&& msg.ascii==48){
                Std.abs(gn-1) => gn;
                gn => out2.gain;  
                <<<"out2.gain: ",gn>>>;            
            } 
            else {
                gn => gn;
            }
        0.1::second => now;
        }
    }
}

fun void vowelShred() {
    while(true){
        for (int i; i < n; i++)  {
            glot => form[i] => volume => out => dac;
            30 => form[i].Q;
            m => volume[i].gain;
            freq[i] => form[i].freq;
            <<<"i=",i,"freq=",freq[i], m>>>;
        }
    }
}


//spork ~ dummy();
spork ~ moveSound();
spork ~ changeF3();
spork ~ printAll();
spork ~ backAll();
spork ~ mute();


//spork ~ vowelShred();


circle();
