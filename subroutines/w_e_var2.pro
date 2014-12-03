;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Returns the temperature dependent emissivity of W   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function w_e_var2, cal_temp

;filename =  unix_to_win('/Rijnh/Shares/Projects/Pilot/Documents/Manuals/IR small/Calibration 2013/emissivity_w_dec5.txt')
filename =  unix_or_win('//Rijnh/Shares/Projects/Pilot/Documents/Manuals/IR small/Calibration 2013/emissivity_w_dec5.txt')
  
openr, lun, filename, /get_lun

length = uint(file_lines(filename))

temp       = dblarr(length)
emissivity = dblarr(length)

buffer = string(0)

for i=0, length-1 do begin
  readf,lun, buffer
  data = strsplit(buffer,/extract)
  temp(i)       = double(data(0))
  emissivity(i) = double(data(1)) 
endfor

close, lun
free_lun, lun


return,interpol(emissivity, temp, cal_temp)

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;