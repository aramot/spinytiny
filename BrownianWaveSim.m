clear all
fieldsize = 256;
figure; a = zeros(fieldsize, fieldsize);
currx = fieldsize/2;
curry = fieldsize/2;
wavecount = 0; rad = 1;
wave = {}; wavelifetime = {};


for i = 1:1000
    a = a.*.99;
    a(currx,curry) = a(currx,curry)+10;
    cla;
    imagesc(a)
    choice1 = randi([-1,1], 1);
    choice2 = randi([-1,1], 1);
    currx = currx+choice1;
    curry = curry+choice2;
    if currx >fieldsize
        currx = currx-1;
    elseif currx <1
        currx = currx+1;
    elseif curry >fieldsize
        curry = curry-1;
    elseif curry<1
        curry = curry+1;
    end
    
    if wavecount >0
        for j = 1:wavecount
            if ~isempty(wave{j})
                theta = (0:1/200:1)*2*pi;
                rad = wavelifetime{j};
                x_center = wave{j}(1);
                y_center = wave{j}(2);
                circle_x = round(sqrt(rad^2*rad^2./(rad^2*sin(theta).^2 + rad^2*cos(theta).^2)).*cos(theta) + x_center);    %%%%% Derives from the formula for an ellipse, wherein X(theta) = a * cos(theta)  
                circle_y = round(sqrt(rad^2*rad^2./(rad^2*sin(theta).^2 + rad^2*cos(theta).^2)).*sin(theta) + y_center);    %%%%% Derives from the formula for an ellipse, wherein Y(theta) = b * sin(theta)
    %             a(circle_x, circle_y) = a(circle_x, circle_y)+2;
                ROImask = roipoly(fieldsize,fieldsize, circle_x, circle_y);
    %             x = round(rad * cos(theta) + x_center);
    %             y = round(rad * sin(theta) + y_center);
    %             a(x,y) = a(x,y) + 5;
                edge = bwperim(ROImask);
                a(edge) = a(edge)+10;
                if ~any(any(edge))
                    wave{wavecount} = [];
                else
                    wavelifetime{j} = wavelifetime{j}+1;
                end
            end
        end
    end
    drawnow
    if a(currx, curry)>20
        wavecount = wavecount+1;
        wave{wavecount} = [currx, curry];
        wavelifetime{wavecount} = 1;
    end
end