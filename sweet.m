% uso [xs,ys]=sweet(x,y,k);
function [xs,ys] = sweet(x,y,k)
%if exist('a'),clear a,end;
n=length(y);
zi=[];zf=[];
for m=1:ceil(k/2)
   zi(m)=y(1);
   zf(m)=y(n);
end
 y=[zi y' zf];
a=1:n;
a=a-a;
for i=1:n
   a(i)=sum(y(i:i+k));
end
a=a/(k+1);
ys=a(1:n);
ys=ys';  %matlab 4
xs=x;

