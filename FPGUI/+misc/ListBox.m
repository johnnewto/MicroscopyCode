classdef ListBox < handle
    properties
        h_listbox;
        textLength = 20;
    end
    
    methods
        % Constructor
        function this = ListBox(h_listbox)
            this.h_listbox = h_listbox;
            set(this.h_listbox, 'String', cell(1));

        end
        
        function Write(this, x)
            DisptoString = @(x)  regexprep(evalc('disp(x)'), '<[^>]*>', '');
            try
                currList = get(this.h_listbox, 'String');
                currList = [currList ; DisptoString(x) ];
                len = length(currList);
                if len > this.textLength
                    currList(1:len-this.textLength) = [];
                end
                set(this.h_listbox, 'String', currList);
                set(this.h_listbox, 'Value', length(currList));
                set(this.h_listbox, 'Listboxtop', length(currList)-1);
            catch
                disp(x)
            end
        end
        
        function Clear(this)
            set(this.h_listbox, 'Value', 1 );
            set(this.h_listbox, 'String', {''});
        end

    end
end
