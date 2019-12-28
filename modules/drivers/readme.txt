The basic concept of the driver dev architecture is as follows:

'family' = multiple drivers that all wrap functionality for a particular family of peripherals
'cluster' = drivers in the same family that all present the same API are in a cluster



Each family has a main folder.
Each family has a Makefile that will build all available clusters in said family. Runs the clusters' makefiles.
Within each family folder are folders, one for each cluster.
Each cluster folder has a Makefile that will build all available drivers in said cluster.
Individual drivers use the following name formatting:

	NAME = "d_<family name>_<cluster name>-<version>_<individual name>"



When built, the outputs will be:

	$(NAME).bin
	$(NAME).list