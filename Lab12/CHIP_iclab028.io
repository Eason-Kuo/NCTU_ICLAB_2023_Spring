######################################################
#                                                    #
#  Silicon Perspective, A Cadence Company            #
#  FirstEncounter IO Assignment                      #
#                                                    #
######################################################

Version: 2

#Example:  
#Pad: I_CLK   W

#define your iopad location here

# NORTH
Pad: VDDP0       N
Pad: GNDP0       N
Pad: I_Port10    N

Pad: VDDP4       N
Pad: GNDP4       N

#
Pad: VDDC0       N
Pad: I_RESET     N
Pad: GNDC0       N
#
Pad: I_VALID        N
Pad: I_VALID_NUM    N
#
Pad: VDDC4       N
Pad: GNDC4       N
#
Pad: I_IN_NUM2  N
Pad: I_IN_NUM1  N
Pad: I_IN_NUM0  N


# EAST
Pad: GNDC1       E
Pad: VDDC1       E

Pad: I_IN_COL3   E
Pad: I_IN_COL2   E
Pad: I_IN_COL1   E
Pad: I_IN_COL0   E

Pad: GNDC5       E
Pad: VDDC5       E

#
Pad: GNDP1       E
Pad: VDDP1       E

Pad: GNDP5       E
Pad: VDDP5       E
#
#

# SOUTH
Pad: I_IN_ROW3   S
Pad: I_IN_ROW2   S
Pad: I_IN_ROW1   S
Pad: I_IN_ROW0   S
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
Pad: O_OUT_3     W
Pad: O_OUT_2     W
Pad: O_OUT_1     W
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
