function nI=shiftView(I,shift)

[n,m,c]=size(I);


a1=shift(1)-floor(shift(1));
a2=shift(2)-floor(shift(2));

s1d=floor(shift(1));
s1u=s1d+1;
s2d=floor(shift(2));
s2u=s2d+1;

ms1=max(abs([s1u,s1d]));
ms2=max(abs([s2u,s2d]));

pI=zeros(n+ms1*2,m+ms2*2,c);
pI(ms1+1:end-ms1,ms2+1:end-ms2,:)=I;

I1d2d=pI(ms1+s1d+1:ms1+s1d+n,ms2+s2d+1:ms2+s2d+m,:);
I1u2d=pI(ms1+s1u+1:ms1+s1u+n,ms2+s2d+1:ms2+s2d+m,:);
I1d2u=pI(ms1+s1d+1:ms1+s1d+n,ms2+s2u+1:ms2+s2u+m,:);
I1u2u=pI(ms1+s1u+1:ms1+s1u+n,ms2+s2u+1:ms2+s2u+m,:);

nI=I1d2d*(1-a1)*(1-a2)+I1d2u*(1-a1)*(a2)+I1u2d*(a1)*(1-a2)+I1u2u*(a1)*(a2);


