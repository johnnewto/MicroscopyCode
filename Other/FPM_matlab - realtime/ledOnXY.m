function ledOnXY(x, y, rgb)
    global ser lastLedXY
    lastLedXY = [x y];
    if isempty(ser)
        ser = serial('COM4');
        fopen(ser);
    end

    centerX = 16;
    centerY = 16;
    fprintf(ser,'%d %d %d %d %d\n', [centerX+x, centerY+y, rgb], 'sync'); 