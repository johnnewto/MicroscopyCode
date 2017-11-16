function lastLedOff()
    global ser lastLedXY
    if isempty(ser)
        ser = serial('COM4');
        fopen(ser);
    end

    centerX = 18;
    centerY = 15;
    fprintf(ser,'%d %d %d %d %d\n', [centerX+lastLedXY(1), centerY+lastLedXY(2), [0 0 0]], 'sync'); 