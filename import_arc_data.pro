function import_arc_data, filename, selected_framelength,filestore

; *****************************************************************          
; This program import a .xls files and saves it in the path specified                     
; 
; Created by:
; D.U.B. Aussems - 10-11-2014
;                                                                 
; *****************************************************************   

; ---------------------------------
; start importing
; ---------------------------------

print, ''
print, 'Start importing file:            ', filename, format='(a,a)'
print, ''


num_rows = uint(file_lines(filename))-2 ; measure number of lines in file
if selected_framelength le 0 then frames = num_rows else frames = min(selected_framelength,num_rows) ; check if selected_framelength is chosen and change frames value if this is the case

close, /all 
openr, lun, filename, /get_lun ; open file
buffer = string(0)

readf, lun, buffer
var_name1 = (strsplit(buffer,/extract)) ; first line contains a list of measured quantity 
var_name1 = [' ',var_name1]
readf, lun, buffer
var_name2 = (strsplit(buffer,/extract)) ; second line contains details of the quantities 

; ---------------------------------
; define import variables
; ---------------------------------

if frames gt 0 then begin
  time = dblarr(frames)
  data1 = dblarr(frames)
  data2 = dblarr(frames)
  data3 = dblarr(frames)
  data4 = dblarr(frames)
  data5 = dblarr(frames)
  data6 = dblarr(frames)
  data7 = dblarr(frames)
  data8 = dblarr(frames)
  data9 = dblarr(frames)
  data10 = dblarr(frames)
  data11 = dblarr(frames)
  data12 = dblarr(frames)
  data13 = dblarr(frames)
  data14 = dblarr(frames)
  data15 = dblarr(frames)
  data16 = dblarr(frames)
  data17 = dblarr(frames)
endif else begin
  time = double (0)
  data1 = double (0)
  data2 = double (0)
  data3 = double (0)
  data4 = double (0)
  data5 = double (0)
  data6 = double (0)
  data7 = double (0)
  data8 = double (0)
  data9 = double (0)
  data10 = double (0)
  data11 = double (0)
  data12 = double (0)
  data13 = double (0)
  data14 = double (0)
  data15 = double (0)
  data16 = double (0)
  data17 = double (0)
endelse

; ---------------------------------
; select what parameters you want
; ---------------------------------

column = [19,22,25,27,36,38,40,41,72,57,26]  

; Rianne's choice:
; 
; 1,2,3 = Cathode current "
; 4,5,6 = Cathode potential "
; 19 = Gas_flows gas_pv1 "
; 22 = Gas_flows gas_pv4 "
; 25 = Gas_flows gas_pv7 "
; 27 = Magnetic_field Magnetic_field "
; 36 = Pressure vessel_press. "
; 38 = Pressure arc_chan_press. "
; 40 = Target Target_V "
; 41 = Target Target_I "
; 72 = Waterflow target "
; 57 = Vessel_temperatures 7_30cm "
; 26 = Laser_power"

  
; ---------------------------------
; put data in variables
; ---------------------------------  

for row = 0, frames-1 do begin
  readf, lun, buffer
  data_string = strsplit(buffer,/extract)
  time(row)   =   double(data_string(0))
  data1(row)   =  double(data_string(1))
  data2(row)  =   double(data_string(2))
  data3(row)  =   double(data_string(3))
  data4(row)  =   double(data_string(4))
  data5(row)  =   double(data_string(5))
  data6(row)  =   double(data_string(6))
  data7(row)  =   double(data_string(column(0)))
  data8(row)  =   double(data_string(column(1)))
  data9(row)  =   double(data_string(column(2)))
  data10(row)  =   double(data_string(column(3)))
  data11(row)  =   double(data_string(column(4)))
  data12(row)  =   double(data_string(column(5)))
  data13(row)  =   double(data_string(column(6)))
  data14(row)  =   double(data_string(column(7)))
  data15(row)  =   double(data_string(column(8)))
  data16(row)  =   double(data_string(column(9)))
  data17(row)  =   double(data_string(column(10)))
endfor

close, lun



; ---------------------------------
; put data structure
; ---------------------------------  

data = create_struct('width',1,'frames',frames,'time',time,$
  'cat_cur',total([data1,data2,data3]),$
  'cat_pot',mean([data4,data5,data6]),$
  'gas_pv1',data7,$
  'gas_pv4',data8,$
  'gas_pv7',data9,$
  'mag_field',data10,$
  'pres_ves',data11, $
  'pres_arc',data12, $
  'V_target',data13, $
  'I_target',data14, $
  'water_target',data15, $
  'temp_ves',data16, $
  'laser_power',data17 $
  )   
   
; ---------------------------------
; saving data structure in save file
; ---------------------------------  

cd, filestore

; extract from filename the date and file number
tmp_file = strsplit(filename, '/', /extract)
n_tmp_file = n_elements(tmp_file)
name = tmp_file[n_tmp_file-1]
date = strmid(name,0,10)
tmp_file2 = strsplit(name, '-', /extract)
n_tmp_file2 = n_elements(tmp_file2)
number = tmp_file2[n_tmp_file2-2]

print,''     
print, 'Saving cascaded-arc_'+date+'_exp'+number+'.sav'
print,''  

save, /VARIABLES,file = 'cascaded-arc_'+date+'_exp'+number+'.sav'

print,''  
print,'>>>  file saved <<<'    
print,''  


end

; -------------------------------------------------------------------------
; Other variable options:
;
;       0                 Time
;       1        Cathode_current        Cathode_1_LEMS
;       2        Cathode_current        Cathode_2_LEMS
;       3        Cathode_current        Cathode_3_LEMS
;       4        Cathode_potential        Cath_volt_1
;       5        Cathode_potential        Cath_volt_2
;       6        Cathode_potential        Cath_volt_3
;       7        Coolingwater_temperatures        Cathodes_1
;       8        Coolingwater_temperatures        Plate_1
;       9        Coolingwater_temperatures        Plate_2
;      10        Coolingwater_temperatures        Plate_3
;      11        Coolingwater_temperatures        Plate_4
;      12        Coolingwater_temperatures        Plate_5
;      13        Coolingwater_temperatures        Nozzle
;      14        Coolingwater_temperatures        Anode
;      15        Coolingwater_temperatures        Cathodes_2
;      16        Coolingwater_temperatures        Target
;      17        Coolingwater_temperatures        Inc.plates
;      18        Coolingwater_temperatures        Inc.target
;      19        Gas_flows        gas_pv1 -> H
;      20        Gas_flows        gas_pv2 
;      21        Gas_flows        gas_pv3
;      22        Gas_flows        gas_pv4 -> Ar
;      23        Gas_flows        gas_pv5 
;      24        Gas_flows        gas_pv6
;      25        Gas_flows        gas_pv7 -> Auxalary
;      26        Laser_power        Laserpower
;      27        Magnetic_field        Magnetic_field
;      28        Plate_potential        cathode_house
;      29        Plate_potential        Plate_1
;      30        Plate_potential        Plate_2
;      31        Plate_potential        Plate_3
;      32        Plate_potential        Plate_4
;      33        Plate_potential        Plate_5
;      34        Plate_potential        Plate_6
;      35        Plate_potential        Anode
;      36        Pressure        vessel_press.
;      37        Pressure        argon_press./vessel_press.
;      38        Pressure        arc_chan_press.
;      39        Pressure        H2_press./gas_inlet_press.
;      40        Target        Target_V
;      41        Target        Target_I
;      42        Vessel_temperatures        Front_flange
;      43        Vessel_temperatures        hp_temp_in
;      44        Vessel_temperatures        hp_temp_1
;      45        Vessel_temperatures        hp_temp_2
;      46        Vessel_temperatures        hp_temp_3
;      47        Vessel_temperatures        hp_temp_4
;      48        Vessel_temperatures        hp_temp_5
;      49        Vessel_temperatures        hp_temp_6
;      50        Vessel_temperatures        hp_temp_7
;      51        Vessel_temperatures        hp_temp_8
;      52        Vessel_temperatures        hp_temp_9
;      53        Vessel_temperatures        hp_temp_10
;      54        Vessel_temperatures        hp_temp_11
;      55        Vessel_temperatures        hp_temp_12
;      56        Vessel_temperatures        6_28cm
;      57        Vessel_temperatures        7_30cm
;      58        Vessel_temperatures        Ring_in
;      59        Vessel_temperatures        Ring_out
;      60        Vessel_temperatures        Target_temp
;      61        Vessel_temperatures        Target_coolingwater
;      62        Waterflow        cathodes_1
;      63        Waterflow        plate_1
;      64        Waterflow        plate_2
;      65        Waterflow        plate_3
;      66        Waterflow        plate_4
;      67        Waterflow        plate_5
;      68        Waterflow        nozzle
;      69        Waterflow        anode
;      70        Waterflow        cathodes_2
;      71        Waterflow        FlowRate9
;      72        Waterflow        target
;      73        Waterflow        rob's_ring
;      74        Waterflow        FlowRate12
;      75        Waterflow        FlowRate13
;      76        Waterflow        FlowRate14
;      77        Waterflow        FlowRate15
;      78        Waterflow        FlowRate16
;      79        Waterflow        FlowRate17
;      80        Waterflow        FlowRate18
;      81        Waterflow        FlowRate19
;      82        Waterflow        HP_cathode_head
;      83        Waterflow        HP_cathode_1
;      84        Waterflow        HP_cathode_2
;      85        Waterflow        defect
;      86        Waterflow        HP_plate_1
;      87        Waterflow        HP_plate_2
;      88        Waterflow        HP_plate_3
;      89        Waterflow        HP_plate_4
;      90        Waterflow        HP_plate_5
;      91        Waterflow        HP_nozzle
;      92        Waterflow        HP_anode
;      93        Waterflow        HP_aux
;      94        Waterflow        FlowRate32
;      95        Waterflow        FlowRate33
;      96        Waterflow        FlowRate34
;      97        Waterflow        FlowRate35
;      98        Waterflow        FlowRate36
;      99        Waterflow        FlowRate37
;     100        Waterflow        FlowRate38
;     101        Waterflow        HP_cathode_3
;     
;     
;     