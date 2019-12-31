the 0c1000 driver will be a full DMA controller driver. 
This means that the driver will manage all of the channels and
not just one. 

likely I will add a 0c2xxx series of drivers that manage only a 
single DMA channel, but we will see.