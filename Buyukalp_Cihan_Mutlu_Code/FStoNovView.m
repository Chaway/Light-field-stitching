function TheImage=FStoNovView(FS,unumber,vnumber)
%unumber and vnumber are the number of perspectives to be generated
%horizontally and vertically, respectively.

fname='palm'; %name tag for saving the images 
%the slope of the back plane, at the end we stabilize all views with respect to it
sclsP00=-0.3041;
%set the middle slope
mids=-0.25;

maxs=0.04623; % Maximum slope
scls=[0:-1:-10]/10*maxs; %Slope values corresponding to 40 different focal lengths
sclsP=[0:-1:-10]/10*maxs;
sclsP0=mids*maxs;
gridw=89; cgridw=45;
[gx,gy]=meshgrid([1:gridw],[1:gridw]);
rad=190; %PSF radius???
crop=10;

%loop over viewpoints 
u=0; v=0; %u,v represent new viewpoint 
iv=1; iu=1;

TheImage=zeros(size(FS,1)-2*crop-10,size(FS,2)-2*crop-10,unumber,vnumber,3);
for u=-36:(72/(unumber-1)):36 %shift the viewpoint horizontally
    for v=-36:(72/(vnumber-1)):36 %shift the viewpoint vertically
        %shift each focal stack image by the disparity shift of [u,v] 
        %times focus slope and compute the average image
        avrgI=0;
        for k=1:length(scls)
            [trI]=shiftView(FS(:,:,:,k),scls(k)*[v,u]); %Shift each focal stack by s*u and s*v
            avrgI=avrgI+trI;
        end
        %crop image boundaries because boundary pixels are missing in the shift
        bn=ceil((maxs*gridw/2+2)*1.1);
        avrgI=avrgI(bn+1:end-bn,bn+1:end-bn,:);

        %building PSF
        PSF=0;
        for k=1:length(sclsP)
            trP=double(((gx-cgridw).^2+(gy-cgridw).^2)<(abs(sclsP(k)-sclsP0)^2*rad.^2));
            trP=trP/max((sclsP(k)-sclsP0)^2,0.0001);
            [trP]=shiftView(trP,(sclsP(k)-sclsP0)*[v,u]);
            trP(find(isnan(trP)))=0;
            PSF=PSF+trP;
        end
        PSF=PSF/sum(PSF(:))*length(scls);

        %zero-pad PSF, and compute Fourier transform 
        tPSF=PSF;
        PSF=zeros(size(avrgI,1),size(avrgI,2));
        dn=(size(PSF,1)-size(tPSF,1))/2;
        dm=(size(PSF,2)-size(tPSF,2))/2;
        PSF(dn+1:end-dn,dm+1:end-dm)=tPSF;
        OTF=fftshift(fft2(ifftshift(PSF)));

        %building 1/f^2 prior for Wiener deconvolution
        eta=0.01; % Image mean value to be used in SNR calculation
        [rn,rm,t]=size(avrgI);
        [grid_x,grid_y]=meshgrid([1:rm]-floor(rm/2)-1,[1:rn]-floor(rn/2)-1);
        grid_y=grid_y/rn*200; grid_x=grid_x/rm*200; 
        invvar=max((grid_y.^2+grid_x.^2),1); % Variance of the noise

        clear nvI

        %Wiener deconvolution
        for t=1:3
         f_avgrI=fftshift(fft2(avrgI(:,:,t)));
         f_avgrI=1/eta^2*conj(OTF)./(1/eta^2*abs(OTF).^2+invvar).*f_avgrI;
         nvI(:,:,t)=ifft2(ifftshift(f_avgrI));
        end

        %stablize with respect to the back plane
        nvI=shiftView(nvI,-(sclsP(k)-sclsP00)*[v,u]);
        
        %crop boundaries damaged by cyclic deconvolution
        nvI=nvI(crop+1:end-crop,crop+1:end-crop,:);

        %figure, imshow(nvI);drawnow;
        TheImage(:,:,iu,iv,:)=nvI(1:1:end,1:1:end,1:1:end);
        iv=iv+1;
    end
    iv=1;
    iu=iu+1;
end