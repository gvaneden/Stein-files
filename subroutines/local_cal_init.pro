;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initializes local calibration, to find temperatures calibrated for your experiment  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function local_cal_init,cal,emis_arr,ir_bg,bg_temp,trans

max_i = size(cal.dl,/n_elements)
temp_arr = fltarr(max_i)
measured_bb_signal = fltarr(max_i)

bg_emis   = interpol(emis_arr,cal.temp,bg_temp+273.14)
bg_signal = interpol(cal.dl,cal.temp,bg_temp +273.14)

for i = long(0),max_i-1 do begin

temp = cal.temp[i]-273.14
temp_arr(i) = temp
bb_signal = cal.dl[i]

measured_bb_signal(i) = trans*(emis_arr[i]*bb_signal-bg_emis*bg_signal)+ir_bg
endfor

return,create_struct('dl',measured_bb_signal,'temp',temp_arr,'length',max_i,'transmission',trans)

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;