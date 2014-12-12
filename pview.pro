pro pview,date,gas

; *****************************************************************          
; This program runs the pview_analysis program for the files of a 
; specific folder                     
; 
; Created by:
; D.U.B. Aussems - 10-11-2014
;                                                                 
; *****************************************************************   

;; -------------------------------------------------
;; Input parameters for code
;; -------------------------------------------------
;
gas = 'He'
date = '2014-11-18'
num='15'


; -------------------------------------------------
; Define time correction values (these values are what you choose as delay time in the PILOT-PSI control environment)
; -------------------------------------------------

time_corr  = 0 ; time delay for IR-camera 
time_corr_pyro = 0
time_corr2 = 0 ; time delay for spectrometer

; Time correction exceptions        
;if date eq '2014-08-25' then begin
;time_corr = 0  
;time_corr2 = 10 
;endif
;if date eq '2014-08-28' then begin
;  if num eq '22' then time_corr = 0
;  if num eq '13' or num eq '14' or num eq '15' then time_corr2=10 else time_corr2=14
;endif

    
; -------------------------------------------------
; get the experiment number and shot number from the spectrometer data 
; -------------------------------------------------

; check what is the experiment number (num2) and shot number (num1)
;path2 = '/Rijnh/Shares/Projects/Pilot/Projects/Damien Aussems/Experiment Campaign 1/Cascaded arc/'+date+'/'
;path =  '/Rijnh/Shares/Projects/Pilot/Projects/Damien Aussems/Experiment Campaign 1/IR/'+date+' Damien/'
;
;list_files_arc = file_search(path2+'*Damien.xls')
;n_files_arc = n_elements(list_files_arc) 
;list_files_IR = file_search(path+'*.SEQ')
;n_files_IR = n_elements(list_files_IR) 
;
;data_IR0 = file_info(list_files_IR[0])
;time_IR0 = data_IR0.mtime

;for i=0,n_files_arc-1 do begin
;  data_arc = file_info(list_files_arc[i])
;  time_arc = data_arc.mtime
;  if time_arc gt time_IR0-20 and time_arc gt time_IR0+100 then begin 
;    ls_arc = strsplit(list_files_arc[i],'-',/extract)
;    n_ls_arc =n_elements(ls_arc)
;    num1_0 = ls_arc[n_ls_arc-2]
;  endif
;endfor
;
;
;for i = 1,n_files_IR-1 do begin
;    
;  ; -------------------------------------------------    
;  ; run pview for selected date and experiment number     
;  ; -------------------------------------------------
;  
;  if i gt 9 then num2  = string(i,format='(I0.0)') else num2  = '0'+string(i,format='(I0.0)') ;format issues
;  num1 = fix(num1_0) + fix(num2)-2
;  num1  = string(num1,format='(I0.0)')
;             
;  pview_analysis,date,num1,num2,'ps',time_corr,time_corr2,gas
;
;endfor
pview_analysis,date,num,'ps',time_corr,time_corr2,time_corr_pyro,gas


end