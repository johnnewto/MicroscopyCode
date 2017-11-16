function openArduino()
    global ard dev;        
    if isempty(ard)
        ard = arduino;
        if isempty(dev)
            dev = spidev(ard, 'D7','Bitrate',20000000);
        end

        if ~strcmp(char(ard.Board), 'Uno')
            error('Could not connect to arduino');
        end

        writeRead(dev,[15 1]); % board all on
        pause(0.1);
        writeRead(dev,[15 0]); % board all off

        writeRead(dev,[9 0]); % Enable max7219 no decode
        writeRead(dev,[10 15]); % Full intensity
        writeRead(dev,[11 7]); % display all digits
        writeRead(dev,[12 1]); % Turn on chip
        for led = 1:8
            writeRead(dev,[led 0]) % Turn off all rows
        end

    end
