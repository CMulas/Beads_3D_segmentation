%% 3D segmentation of cells embeded in agarose beads
% 
% Functions required: 
% 1. ordfilt3D - Olivier Salvado (2020). ordfilt3 
% (https://www.mathworks.com/matlabcentral/fileexchange/5722-ordfilt3), 
% MATLAB Central File Exchange. 
%
% 2. imshow3D - Maysam Shahedi (2020). imshow3D 
% (https://www.mathworks.com/matlabcentral/fileexchange/41334-imshow3d), 
% MATLAB Central File Exchange. 
%
% 3. lsmread - CY Y (2020). Zeiss Laser Scanning Confocal Microscope LSM file reader 
% (https://www.github.com/joe-of-all-trades/lsmread), 
% GitHub. 
%
%
%
%

folder='test/';
commonID = 'images_2018_05_16__12_44_06'; %file naming system
number_stacks = 11; %total number of z-stacks per image position
timer=59; %number of timepoints collected
positions=16; %user imput, total number of positions

counter=1; %unique counter for the number of images analysed
time=1; %starting time 



for time=1:timer           %goes through all timepoints collected
    
    for pos=1:positions    %goes through all positions at a given timepoint
        
        %% 1 - Import .lms files and split each channel
          if (pos < 10) && (time < 10)
            pok=num2str(pos);
            timk=num2str(time);
            filename=strcat(folder, commonID, '__t0',timk,'_p0',pok,'.lsm');
            filex=lsmread(filename);
          elseif (pos > 10) && (time <10)
            pok=num2str(pos);
            timk=num2str(time);
            filename=strcat(folder, commonID, '__t0',timk,'_p',pok,'.lsm');
            filex=lsmread(filename);
          elseif (pos < 10 ) && (time > 10) 
            pok=num2str(pos);
            timk=num2str(time);
            filename=strcat(folder, commonID, '__t',timk,'_p0',pok,'.lsm');
            filex=lsmread(filename);
           elseif (pos > 10 ) && (time > 10) 
            pok=num2str(pos);
            timk=num2str(time);
            filename=strcat(folder, commonID, '__t',timk,'_p',pok,'.lsm');
            filex=lsmread(filename);
          end
        A=squeeze(filex);
        ch1=squeeze(A(1,:,:,:));  
        ch2=squeeze(A(3,:,:,:));
        ch3=squeeze(A(2,:,:,:));
        
        GFP=permute(ch1, [3 2 1]);
        mT=permute(ch2, [3 2 1]);
        BF=permute(ch3, [3 2 1]);
          
        figure;imshow3D(GFP);

        

        %% 2- mT channel pre-processing  
        im1_medfilt=ordfilt3D(mT, 14); 
        
        %% 3- Thresholding of mT channel based on centre position of Z-stack
        % for most images, the first threshold was apropriate.
        
        gthresh=multithresh(im1_medfilt(:,:,6), 3); 

        bw3=false(size(mT));

        for k=1:size(mT,3)
              bw3(:,:,k)=im2bw(im1_medfilt(:,:,k),im2double(gthresh(1)));
        end

        figure;imshow3D(bw3);

        %% 4- Cleanup of binary mT mask
        bw2=imdilate(bw3, strel('sphere',2));
        bwclean=imfill(bw2, 'holes');
        bwclean2=imclose(bwclean,strel('sphere',5));
        %figure;imshow3D(bwclean2);

        %% 5- Segmentation and determining pixels containing cells
        %find connected components(i.e. cells, and remove small debris)
        
        connectedcomp=bwconncomp(bwclean2, 26);
        CellProperties=regionprops('table', connectedcomp, 'BoundingBox', 'PixelIdxList', 'Centroid', 'SubarrayIdx', 'Area');
        toDelete=CellProperties.Area<5000;
        CellProperties(toDelete,:)=[];
        
        
        %% 6- Get fluorescence levels and write output - 
        % note: gets overwritten with every cycle 
        % if no cells are detected (i.e. cell escapes), all fields are zero 
        % if there are multiple cells, the fields are set to -1, and need
        % to be manually  analysed.

        if size(CellProperties,1)==0
            Res1=table(time, pos, 0, 0, 0);
        elseif size(CellProperties,1)==1
            GFPlevel=GFP(CellProperties.PixelIdxList{1});
            GFPmean=mean(GFPlevel);
            mTlevel=mT(CellProperties.PixelIdxList{1});
            mTmean=mean(mTlevel);
            Volume=CellProperties.Area;
            Res1=table(time, pos, GFPmean, mTmean, Volume);
        else
            Res1=table(time, pos, -1, -1, -1);     
        end

        Results(counter,:)=Res1         %final results table
        
        writetable(Results, "Results.txt");
        counter=counter+1;
        
        %cleanup used variables for next cycle
        clearvars GFP GFPlevel GFPmean gthresh im1_medfilt mT mTlevel mTmean Res1 ch1 ch2;
        clearvars bw2 bwclean bwclean2 connectedcomp CellProperties
    end
end


