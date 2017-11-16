
% https://au.mathworks.com/help/matlab/matlab_oop/events-and-listeners--syntax-and-techniques.html

classdef CameraGui < handle
   properties
      State = false
      h_evtImageGrabbed % Property for listener handle
      h_imagePlot  % handle of the image data
      count = 0;
      run = false;
   end
   events
      evtImageGrabbed
   end
   methods
        % constructor
        function this = CameraGui(gaxis, img)
            global gui_h
            axes(gaxis); 
            this.h_imagePlot = imshow(img,[]); axis image;
            this.h_evtImageGrabbed = addlistener(this,'evtImageGrabbed',@CameraGui.EvtImageGrabbed);
        end
        
        function startPlot(src)
            
            src.run = true;

            while src.run
                disp('plot') 
                notify(src,'evtImageGrabbed');
                pause(0.01);
            end
        end

        function stopPlot(src)
            src.run = false;
        end
        
   end
   
   methods (Static)
      
      function EvtImageGrabbed(src,~)
%          doplot(src);
      end
   end
   
end    



