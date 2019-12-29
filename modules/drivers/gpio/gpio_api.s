# include me into the kernel for ease of use! 
# this file will a layer of abstraction between the kernel and
# GPIO drivers to -
#   A. Make using the driver much easier
#   B. Handle determining which individual driver to use

# I would like the build system to automatically determine which driver(s) to package with the kernel 
# and present a decent interface to make accesing driver functionality easier. 

