function [x,y]=findsrccoord(source,noSourcesstrike,noSourcesdip)

sourceindex=0;


for j=1:noSourcesdip 
    for i=1:noSourcesstrike

        srcno=i+sourceindex;
          if source==srcno
              y=i;
              x=j;
          else
          end
                  
    end
     sourceindex=sourceindex+i;
end
