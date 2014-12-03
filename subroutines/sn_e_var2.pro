;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Returns the temperature dependent emissivity of Sn  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function sn_e_var2, temp

e0=0.05
a=6.86359E-5
b=0.004


emiss_arr = a*temp +b

change = where(emiss_arr lt e0)

if change[0] ne -1 then emiss_arr[change] = e0

return, emiss_arr

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
