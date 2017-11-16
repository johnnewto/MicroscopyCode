function ledOnXY(x, y)
    global ser
    if isempty(ser)
        ser = serial('COM4');
        fopen(ser);
    end

    centerX = 18;
    centerY = 15;
    fprintf(ser,'%d %d\n', [centerX+x, centerY+y], 'sync'); 