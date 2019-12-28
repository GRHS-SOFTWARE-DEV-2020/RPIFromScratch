big picture goal is to have both 32 and 64 bit backends completely the same in terms of API presented to user applications.
this kind of flexiblity takes away pressure for developers to make seperate versions of their programs.

In order to reflect this principle, each module will exist in a folder with a 32 and 64 bit version of itself.
General structure of the final program is as follows, fairly straightforward:

	Drivers -> Kernel -> OS -> User Applications



The HW Drivers are meant to attempt to provide a relatively consistant API for the hardware they wrap.
	- Very small
	- Very fast
	- Probably always assembly
	- There are many many many of these, like 1 per board per driver family
	- Provides an interface for the Kernel to use


(SW Drivers are slightly more high level and are not to be worried about rn)


The Kernel 
	- Small, but noticeably bigger that drivers
	- Manages low level resources
	- Boots the OS after preparing the board
	- There will be roughly 1 kernel version per family of boards (so way fewer than drivers)






In order to reduce compile times I will implement a system to only recompile that which has been changed or is dependent on something
that has changed (so a dependency tree). Once you've built the project, just copy the contents of the relevant folder from the 'out' 
directory ( ./out/<rpi>/ ) into the micro sd card. The build system should handle setting up bootloaders and such. The "build" folder 
contains the compiled outputs sans raspberry pi bootloading + config files. This is so that the images can be built into the "build" 
folder once and then used many times to build working bootable cards for many different platforms. 