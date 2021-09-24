
# Clock
set_location_assignment PIN_Y2 -to clk

# Reset
set_location_assignment PIN_M23 -to rst_n

# I2C
set_location_assignment  PIN_D14 -to i2c_SCL
set_location_assignment  PIN_E14 -to i2c_SDA

# Other

set_location_assignment PIN_M21 -to write_n
set_location_assignment PIN_N21 -to read_n

set_location_assignment PIN_AB28 -to addr[0]
set_location_assignment PIN_AC28 -to addr[1]
set_location_assignment PIN_AC27 -to addr[2]
set_location_assignment PIN_AD27 -to addr[3]
set_location_assignment PIN_AB27 -to addr[4]
set_location_assignment PIN_AC26 -to addr[5]
set_location_assignment PIN_AD26 -to addr[6]
set_location_assignment PIN_AB26 -to addr[7]

set_location_assignment PIN_AC25 -to data[0]
set_location_assignment PIN_AB25 -to data[1]
set_location_assignment PIN_AC24 -to data[2]
set_location_assignment PIN_AB24 -to data[3]
set_location_assignment PIN_AB23 -to data[4]
set_location_assignment PIN_AA24 -to data[5]
set_location_assignment PIN_AA23 -to data[6]
set_location_assignment PIN_AA22 -to data[7]

set_location_assignment PIN_G19 -to display[0]
set_location_assignment PIN_F19 -to display[1]
set_location_assignment PIN_E19 -to display[2]
set_location_assignment PIN_F21 -to display[3]
set_location_assignment PIN_F18 -to display[4]
set_location_assignment PIN_E18 -to display[5]
set_location_assignment PIN_J19 -to display[6]
set_location_assignment PIN_H19 -to display[7]
set_location_assignment PIN_J17 -to display[8]
set_location_assignment PIN_G17 -to display[9]
set_location_assignment PIN_J15 -to display[10]
set_location_assignment PIN_H16 -to display[11]
set_location_assignment PIN_J16 -to display[12]
set_location_assignment PIN_H17 -to display[13]
set_location_assignment PIN_F15 -to display[14]
set_location_assignment PIN_G15 -to display[15]

set_location_assignment PIN_E21 -to complete