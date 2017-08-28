Prior To Starting
1. Download the Wave_Clus toolbox from Github https://github.com/csn-le/wave_clus
2. Once downloaded and placed within Matlab path, open up set_paramters.m and set_parameters_DEAFAULT.m within 
	the Wave_Clus directory.
	- You will need to chnage the settings in these files to match the settings within the MERAnalysis 
		main script file
	- There is a bug within the Wave_Clus detection fucntion that will ignore the parameters within the 
		MERAnalysis script and will use the paramters within these files. 
	- I haven't had time to debug the Wave_Clus functions as of yet, I will in the next few weeks

Right Before Running
1. Ensure you place ALL dbs patient folders to be analysed within the allData folder
2. Make sure you place the 'Patient Info.xlsx' file within the mainFolder 'MERAnalysis'

Final Data Structure

D.StudyNumLeft 
	This field indicates the study number index from the Leadpoint files. This number is what the Leadpoint 
	system assigns to the left side (and also to the right side). These numbers are only required when 
	extracting data from the raw Leadpoint files.

D.LeftDepths 
	This field indicates the depth for each recording (meaning how far down the microelectrodes are, and how 
	far away they are from the target). This information is critical when doing our analysis because the 
	planned "0" point is the middle of the STN. The numbers start at -10 (meaning 10mm above the target STN) 
	and increase towards 0. The positive values indicate going past the middle of STN (these positive values 
	usually extend to ~ +5mm). This is an {Patient} cell array. Each column within the cell array represents 
	the depth in millimeters. The numbers always go from negative to positive (negative indicating above STN 
	target and positive indicating below STN target).

D.LeftCluster 
	This field holds the critical information about the spikes themselves. The first column is the cluster 
	number and the second column is the timestamp for that spike. This is an {Patient}{# of channels x depth} 
	cell array. Within each cell, the first column is the spike cluster and the second column is the spike 
	time, each row represents a new spike. 

D.LeftInspk 
	This field holds the raw spike data that was then upsampled by interpolation in the Wave_clus algorithm. 
	We use the spleen method to upsample the data. This is an {Patient}{# of channels x depth} cell array. 
	Each row is a new spike and each column is the raw data representing that spike. 

D.LeftlPermut 
	This field houses the permutation number associated with each spike. This is used by Wave_clus during 
	template matching, not really important for our work. This is an {Patient}{# of channels x depth} cell 
	array. Within each cell, each column represents a different index from the permutation algorithm used 
	during template matching. 

D.LeftInDep 
	This field is the depth at which the surgeon determined we were within the STN based on visual inspection 
	of the spike train data on the screen in the operating room.

D.LeftOutDep 
	This field is the depth at which the surgeon determined we had passed through the STN and were now leaving 
	the STN. 