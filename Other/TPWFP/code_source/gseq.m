function seqf=gseq(arraysize)
    n=(arraysize+1)/2;
    arraysize=2*n-1;
    sequence=zeros(2,arraysize^2);
    sequence(1,1)=n;
    sequence(2,1)=n;
    dx=+1;
    dy=-1;
    stepx=+1;
    stepy=-1;

    direction=+1; %+1 means x direction, -1 means y direction
    counter=0;

    for i=2:arraysize^2
        counter=counter+1;

        if direction==+1
            sequence(1,i)=sequence(1,i-1)+dx;
            sequence(2,i)=sequence(2,i-1);
            if counter==abs(stepx)
                counter=0;
                direction=direction*-1;
                dx=dx*-1;
                stepx=stepx*-1;
                if stepx>0
                    stepx=stepx+1;
                else
                    stepx=stepx-1;
                end

            end

        else
            sequence(1,i)=sequence(1,i-1);
            sequence(2,i)=sequence(2,i-1)+dy;

            if counter==abs(stepy)
                counter=0;
                direction=direction*-1;
                dy=dy*-1;
                stepy=stepy*-1;

                if stepy>0
                    stepy=stepy+1;
                else
                    stepy=stepy-1;
                end

            end

        end
    end
    seq=(sequence(1,:)-1)*arraysize+sequence(2,:);
    seqf(1,1:arraysize^2)=seq;
    temp=gseq2(arraysize);
    seqf(1,arraysize^2+1:2*arraysize^2-1)=temp(end-1:-1:1);
    
end

function seq=gseq2(arraysize)
    n=(arraysize+1)/2;
    arraysize=2*n-1;
    sequence=zeros(2,arraysize^2);
    sequence(1,1)=n;
    sequence(2,1)=n;
    dx=-1;
    dy=+1;
    stepx=+1;
    stepy=-1;

    direction=-1; %+1 means x direction, -1 means y direction
    counter=0;

    for i=2:arraysize^2
        counter=counter+1;

        if direction==1
            sequence(1,i)=sequence(1,i-1)+dx;
            sequence(2,i)=sequence(2,i-1);
            if counter==abs(stepx)
                counter=0;
                direction=direction*-1;
                dx=dx*-1;
                stepx=stepx*-1;
                if stepx>0
                    stepx=stepx+1;
                else
                    stepx=stepx-1;
                end

            end

        else
            sequence(1,i)=sequence(1,i-1);
            sequence(2,i)=sequence(2,i-1)+dy;

            if counter==abs(stepy)
                counter=0;
                direction=direction*-1;
                dy=dy*-1;
                stepy=stepy*-1;

                if stepy>0
                    stepy=stepy+1;
                else
                    stepy=stepy-1;
                end

            end

        end
    end

    seq=(sequence(1,:)-1)*arraysize+sequence(2,:);
end
