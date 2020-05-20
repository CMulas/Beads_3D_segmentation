# Segmentation of cells embedded in 3D agarose aggregates

Publication reference: 
Microfluidic platform for live cell imaging of 3D cultures with clone retrieval
Carla Mulas, Andrew C Hodgson, Timo N Kohler, Chibeza C Agley,  Florian Hollfelder,  Austin Smith,  Kevin Chalut
doi: https://doi.org/10.1101/2020.02.17.952689

Outline: 
* input: z-stacks of cell aggregates embedded in agarose/fibrin/laminin hydrogel beads. Cells express a constitutive membrane marker (mTomato or mT) and Rex1::GFPd2. 
* action: 3D segmentation of aggregate and determine mean expression of GFP and mTomato
* output: Table with time, position, GFP mean expression, mTomato mean expression

Input files:
* .lsm files are automatically exported from the imaging software (Zeiss Blue) after each imaging round. The files contain z-stacks for brightfield, GFP and mT channel. 

![Filename](https://user-images.githubusercontent.com/61800079/82453995-2a6a9500-9aa9-11ea-9b46-a67f70e97c89.png)

Steps:
1. Import file for a given position and timepoint and separate GFP and mT channel. 
2. Pre-process mT channel [REF1]
3. Determine threshold on mT channel
4. Clean binary mT image
5. Segment in 3D
6. Calculate mean GFP and mT levels

Repeat steps 1-6 for each position, and for each timepoint. 

# 1- Import files and separate channels
Raw images

![raw images](https://user-images.githubusercontent.com/61800079/82464477-0ceff800-9ab6-11ea-9011-cf999e03c663.png)

# 2- Processing mT channel 
Clean raw image with 3-D order-statistic filtering on 26 neighbours

![processing](https://user-images.githubusercontent.com/61800079/82464191-b1be0580-9ab5-11ea-94f3-176a04dec96b.png)


# 3- mT threshold

![thresholding](https://user-images.githubusercontent.com/61800079/82464240-c13d4e80-9ab5-11ea-9516-3f96150aebdb.png)

# 4- Clean up binary image

![Cleanup](https://user-images.githubusercontent.com/61800079/82464289-d0bc9780-9ab5-11ea-97b9-4d6f5ab01cf3.png)




# Functions required: 
1. ordfilt3D - Olivier Salvado (2020). ordfilt3 
 (https://www.mathworks.com/matlabcentral/fileexchange/5722-ordfilt3), 
 MATLAB Central File Exchange. 

2. imshow3D - Maysam Shahedi (2020). imshow3D 
 (https://www.mathworks.com/matlabcentral/fileexchange/41334-imshow3d), 
 MATLAB Central File Exchange. 

3. lsmread - CY Y (2020). Zeiss Laser Scanning Confocal Microscope LSM file reader 
 (https://www.github.com/joe-of-all-trades/lsmread), 
 GitHub. 
