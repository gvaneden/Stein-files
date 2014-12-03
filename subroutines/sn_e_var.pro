;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Returns the temperature dependent emissivity of Sn  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function sn_e_var, cal

e0=0.05
a=6.86359E-5
b=0.004

emis_arr = fltarr(cal.width)
max_i = size(cal.dl,/n_elements)

for i=long(0), max_i-1 do begin

temp = cal.temp[i]-273.14
if temp lt (e0-b)/a then emis_arr[i]=e0 else emis_arr[i]= a*temp + b

endfor

return, emis_arr

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
