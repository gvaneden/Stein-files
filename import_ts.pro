pro import_TS, date, num, n_e, T_e , flux, gas

; *****************************************************************          
; This program imports the maximum n_e, T_e values and caculates the 
; flux                    
; 
; Created by:
; D.U.B. Aussems - 12-11-2014
;                                                                 
; *****************************************************************   

; --------------------------------
; modify input data
; --------------------------------  

date_str = strsplit(date,'-',/extract)
year = date_str[0]
month = date_str[1]
day = date_str[2]

if num gt 9 then num_file  = string(num,format='(I0.0)') else num_file  = '0'+string(num,format='(I0.0)') ;format issues

; --------------------------------
; Specify path and filename
; --------------------------------

path = '/Rijnh/Shares/Projects/Pilot/Processed Data/Thomson Scattering/'+year+'-'+month+'/'+date+'/ASCII/'
file = 'TNP_ascii_'+year+month+day+'_0'+num_file+'.dat' ; only goes up to 99! 
filename = path+file 

if file_search(filename) ne '' then begin

; --------------------------------
; Import data
; --------------------------------

num_rows = uint(file_lines(filename))-10
close,/all
openr, lun, filename, /get_lun

header =   strarr(10) 
readf, lun, header ; import header

; Define variables
n_e = float(0)
T_e = float(0)
data = string(0) 

readf, lun, n_e,T_e,data ; import line in which n_e and T_e values are given

; --------------------------------
; Process data
; --------------------------------


if gas eq 'H'  then m_p = 1.67E-27*1.0079
if gas eq 'He' then m_p = 1.67E-27*4.0026/2 ; /2 because atomic helium
if gas eq 'Ar' then m_p = 1.67E-27*39.948

flux =0.5*n_e*SQRT(4/3*1.60E-19*T_e/m_p) ; ion flux = n_e/2 * sqrt(k_b (T_e + gamma*T_i)/m_i) = n_e/2 * sqrt(4*k_b*T_e)/(3*m_i))

endif

end


