% s = serial('COM4');
% set(s,'BaudRate',9600);
% fopen(s);
% fprintf(s,'*IDN?')
% while (1)
%     out = fscanf(s)
% end
% fclose(s)
% delete(s)
% clear s
% Create a serial port object.
ser = []; % instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(ser)
    ser = serial('COM4');
else
    fclose(ser);
    ser = ser(1)
end

% Connect to instrument object, obj1.
fopen(ser);
pause(2)

% Communicating with instrument object, obj1.
for j=1:10
    for i = 0:31
        fprintf(ser,'%d %d\n', [i i], 'sync');
        pause(0.01)
    end
    for i = 31:-1:0
        fprintf(ser,'%d %d\n', [i 31], 'sync');
        pause(0.01)
    end
    for i = 31:-1:0
        fprintf(ser,'%d %d\n', [0 i], 'sync');
        pause(0.01)
    end
end
% Disconnect from the serial port.
fclose(ser);

% Clean up all objects.
delete(ser);