######################################################
#                                                    #
#  Silicon Perspective, A Cadence Company            #
#  FirstEncounter IO Assignment                      #
#                                                    #
######################################################

Version: 2

#Example:  
#Pad: I_CLK 		W

#define your iopad location here

Pad: VDDP0       N
Pad: GNDP0       N

Pad: VDDP4       N
Pad: GNDP4       N

#
Pad: VDDC0       N
Pad: I_RESET     N
Pad: GNDC0       N
#
Pad: I_VALID     N
Pad: I_VALID2    N
#
Pad: VDDC4       N
Pad: GNDC4       N


# EAST
Pad: GNDC1       E
Pad: VDDC1       E
Pad: I_IN_MAT1   E

Pad: GNDC5       E
Pad: VDDC5       E

#
Pad: GNDP1       E
Pad: VDDP1       E

Pad: GNDP5       E
Pad: VDDP5       E
#
Pad: I_IN_MAT0   E
Pad: I_IN_MATRIX E
#

# SOUTH
Pad: I_IN_I_IDX  S
Pad: I_IN_W_IDX  S
#
Pad: VDDC2       S
Pad: I_CLK       S
Pad: GNDC2       S

Pad: VDDC6       S
Pad: GNDC6       S
#
Pad: VDDP2       S
Pad: GNDP2       S

Pad: VDDP6       S
Pad: GNDP6       S
#


# WEST
Pad: O_OUT_0     W
Pad: O_VALID     W
#
Pad: VDDP3       W
Pad: GNDP3       W
#
Pad: VDDC3       W
Pad: GNDC3       W

Pad: VDDP7       W
Pad: GNDP7       W
#
Pad: VDDC7       W
Pad: GNDC7       W


#
Pad: PCLR SE PCORNER
Pad: PCUL NW PCORNER
Pad: PCUR NE PCORNER
Pad: PCLL SW PCORNER
