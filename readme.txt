Mouse Lung Automated Segmentation Tool (MLAST)
Mary Kate Montgomery
August 2019

Standalone MATLAB Application to perform automated segmentation of lung-field micro-Computed Tomography Scans
-------------------------------------------------------------------------------------------------------------

Purpose: 
	The Mouse Lung Automated Segmentation Tool (MLAST) was designed to perform automated mCT segmentation 
	in analysis of lung scans for murine Non-Small Cell Lung Cancer models.
-------------------------------------------------------------------------------------------------------------

Inputs:
   1. Study Directory
	- Hit "Select" to open a file browser, from which you will select the parent directory for the study 
	  you want to analyze.
   2. Scan Log
	- Hit "Select" to open a file browser, from which you will select the scan log (in Excel format) 
	  which contains identifying information for the scans you want to analyze.
   3. Scan Log Sheet
	- Select the name of the sheet or tab in the scan log which contains the relevant identifying 
	  information for the scans you want to analyze. 
   4. Mouse Header
	- Select the name of the header of the column you want to use to sort the scans you are analyzing. 
	  The algorithm uses information in the names of the folder structure to identify each scan, so 
	  select the column which contains information that will match the folder names.
   5. Output File Name
	- Enter the name of the Excel (.xlsx) workbook that the program will create. The default is "MLAST 
	  Results".
   6. Metrics to Report
	- Choose to save only the default information by selecting "Lung Tumor Scan" or select your own 
	  combination of information to save by selecting "Customize"
	- The default choices are "Tissue Volumes" and "Tissue Percentages". This means the output file will 
	  contain the volumes and percentages of the total thoracic cavity for lung, soft tissue, 
	  intermediate, and combined (soft tissue + intermediate).
	- Other options include mean densities (normalized or raw) for all tissue types, the total thoracic 
	  volume, the volume of the measured diaphragm, the total image size (in pixels), the threshold used 
	  to segment bone, and the volume of the bone that was segmented.
	- Users have the option to select multiple choices using the shift and ctrl keys.
	- Changing the "Metrics to Report" button returns the selection to the default.
   7. Advanced Options
	a. Items to Save
	     - Check "Export Results" to save an Excel (.xlsx) workbook with the selected metrics to report 
	       for all scans. The program selects this option by default.
	     - Check "Save QC Labels" to save the MLAST segmentation of scans which have been flagged for QC 
	       as a tiff stack. The program selects this option by default.
	     - Check "Save All Labels" to save the MLAST segmentation of all scans as a tiff stack. The 
	       program deselects this option by default.
	     - Check "Save .mat File" to save all MLAST results as a MATLAB file. The program deselects this 
	       option by default.
	b. Thresholding Methods
	     - Select "Kmeans" to threshold between tissues using a 1-dimensional k-means clustering 
	       algorithm. This option will take longer than Otsu, and it will not return the exact same 
	       threshold value for a given scan every time, but it will be more accurate in scans with an 
	       extremely high tumor burden. 
	     - Select "Otsu" to use an Otsu thresholding approach to separate tissues. This option will be 
	       significantly faster than Kmeans, and it will give exactly the same results for a given scan 
	       every time, but it will falter in scans with an extremely high tumor burden. This option is 
	       recommended for testing and for large datasets, but not for scans in which high tumor burden 
	       is expected.
	     - The program selects "Kmeans" by default.
-------------------------------------------------------------------------------------------------------------

The Algorithm:

MLAST was written using Matlab R2017b, including the Image Processing, Statistics and Machine Learning, and 
Parallel Computing toolboxes. First, scans are thresholded to identify bone. Then an outline of the exterior 
of the thoracic cavity is created by interpolating between rib regions and is used as a mask for the thoracic 
cavity. A one-dimensional implementation of the unsupervised machine learning algorithm k-means clustering 
breaks pixels into clusters according to density. The resulting clusters are matched to three tissue types: 
soft tissue, lung, and intermediate. ?

The z-slice where the two tracheal regions collide is used as the cranial cutoff for the mask. Then the upper 
limit of the diaphragm is identified using each pixel’s inflection point along the z-axis. All tissue 
identified as diaphragm is removed from the thoracic cavity and therefore from the volumes of the segmented 
tissues. The results are expressed in terms of the percentage of the thoracic cavity which is made up of 
lung. Decreases in this lung percentage can be attributed to increases in tumor burden.?

-------------------------------------------------------------------------------------------------------------

Outputs:
   1. Results Workbook
	- The program creates an Excel (.xlsx) workbook if the "Export Results" option is checked.
	- The workbook contains one sheet or tab for each output metric. If the metric applies to all tissue 
	  types, the workbook contains separate sheets for each tissue type.
	- The results are sorted by comparing the names of the folder structure containing a given scan 
	  against the column of subject identifiers indicated by the "Mouse Header" selection.
	- Each row is colored according to the color of that subject's identifier in the Scan Log.
	- All scans for a given scan are sorted according to the date on which the scan occurred (read from 
	  the scan's log file). These dates are displayed at the top of the data table.
	- Any scans that could not be matched to a subject ID are placed under the data table with all 
	  metadata pulled from the folder structure. The user can then determine where the unidentified scan 
	  should be placed.
	- Any scans that have been flagged for QC are marked with red text on a red background. The algorithm 
	  flags any scans with an abnormally low thoracic volume (probable masking error), an abnormally low 
	  diaphragm volume (probable diaphragm error), an abnormally high bone volume (severe motion 
	  artifact), or an abnormally high soft tissue percentage (severe motion artifact). Users can then 
	  view the saved Segmentation Image to determine if the scan's data should be included in analysis or 
	  not.
   2. Segmentation Images
	- The program saves tif stacks of the MLAST Segmentation Results for any scans flagged for QC if the 
	  "Save QC Labels" box is checked. If the "Save All Labels" box is checked, the program saves these 
	  images for all scans.
	- The images are placed inside the recon folder for each scan in a folder called "MLAST_Results".
	- The segmentation results correspond to a numeric code as follows:
		0: Background
		1: Bone
		2: Diaphragm
		3: Lung
		4: Intermediate
		5: Soft Tissue
	- The images can be loaded into a 3D viewing software such as Amira and compared side-by-side with 
	  the scans themselves.
   3. MLAST Log
	- The program automatically generates a log file in the Study Directory that records the time, user, 
	  computer, and parameters used in each MLAST analysis performed on the study.
	- Running MLAST multiple times will result in multiple entries within the same log file. The entries 
	  will be sorted with the newest at the bottom.
   4. MATLAB file
	- The program will save a .mat file titled "AllData.mat" if the "Save .mat File" option is checked.
	- The .mat file contains the MLAST results, unsorted, for all scans in the study. It is intended to 
	  be used for QC only, as it is relatively large and totally inaccessible without MATLAB.
-------------------------------------------------------------------------------------------------------------