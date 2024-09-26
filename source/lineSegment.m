%%
function [lines] = lineSegment(BW,img)

% figure(3); clf(3); imshow(BW);

width = size(img,2);
height = size(img,1);

[H,theta,rho] = hough(BW);
% figure
% imshow(imadjust(rescale(H)),[],...
%        'XData',theta,...
%        'YData',rho,...
%        'InitialMagnification','fit');
% xlabel('\theta (degrees)')
% ylabel('\rho')
% axis on
% axis normal 
% hold on
% colormap(gca,hot)

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
% x = theta(P(:,2));
% y = rho(P(:,1));
% plot(x,y,'s','color','black');

lines = houghlines(BW,theta,rho,P,'FillGap',80,'MinLength',100);

% clustering
thetas = extractfield(lines,'theta');
thetas = thetas';
rhos = extractfield(lines,'rho');
rhos = rhos';
idx = kmeans([thetas,rhos],2);
lines_temp = lines(1:2);
lines_temp(1) = lines(find(idx==1,1));
lines_temp(2) = lines(find(idx==2,1));
lines = lines_temp;

% figure(2); clf(2); imshow(img); hold on
% max_len = 0;
% for k = 1:length(lines)
%     theta = lines(k).theta;
%     rho = lines(k).rho;
%     % check upper border
%     y1 = 1;
%     x1 = (y1 - (rho/sind(theta)))/(-cosd(theta)/sind(theta));
%     if x1<1 || x1>width
%         if x1<1
%             x1 = 1;
%         elseif x1>width
%             x1 = width;
%         end
%         y1 = x1*(-cosd(theta)/sind(theta)) + (rho/sind(theta));
%     end
%     lines(k).point1 = [x1,y1];
%     % check bottom border
%     y2 = height;
%     x2 = (y2 - (rho/sind(theta)))/(-cosd(theta)/sind(theta));
%     if x2<1 || x2>width
%         if x2<1
%             x2 = 1;
%         elseif x2>width
%             x2 = width;
%         end
%         y2 = x2*(-cosd(theta)/sind(theta)) + (rho/sind(theta));
%     end
%     lines(k).point2 = [x2,y2];
%     
%     xy = [lines(k).point1; lines(k).point2];
%     plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%     % Plot beginnings and ends of lines
%     plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%     plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%     % Determine the endpoints of the longest line segment
%     len = norm(lines(k).point1 - lines(k).point2);
%     if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%     end
% end
% % highlight the longest line segment
% plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');pause(0.1);
end