function import_calibration, filter

;pathname =  unix_or_win('//Rijnh/Shares/Projects/Pilot/Documents/Manuals/IR small/Calibration 2013/Calibration Files/')
pathname =  '//Rijnh/Shares/Projects/Pilot/Documents/Manuals/IR small/Calibration 2013/Calibration Files/'

case filter of
  1: filename = 'filter1_calibration_extra.txt'
  2: filename = 'filter2_calibration_extra.txt' 
  3: filename = 'filter3_calibration_extra.txt'
  else: begin
     print, '****************************'
     print, '* Invalid filter number!!! *'
     print, '****************************'   
  end
endcase
    
openr, lun, pathname + filename, /get_lun

buffer = string(0)
readf, lun, buffer
width  = ulong(float(buffer))

readf, lun, buffer
offset = fix(buffer)

buffer = strarr(width)
readf, lun, buffer
dl     = double(float(buffer))
readf, lun, buffer
temp   = double(buffer) 

close, lun

return, create_struct('width',width,'offset',offset,'dl',dl,'temp',temp)

end