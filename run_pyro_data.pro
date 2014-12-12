pro run_pyro_data

; *****************************************************************          
; This program imports all pryometer data of a specific folder              
; and saves them in the path specified            
; 
; Created by:
; D. van den Bekerom - ??-??-2012
; 
; Modified by:                                
; D..U.B. Aussems - 10-11-2014                                                                 
; *****************************************************************     

; ------------------
; set path and date ;
; ------------------
;input:
date = '2014-11-18'
start_path = '/Rijnh/Shares/Projects/Pilot/Measurement Data/Pyrometer/2014-11-17 Stein/'
path=start_path+date
;output:
outputfolder= '11-2014 Sn exposure Pilot/processed data'
filestore = '/home/emc/eden/My Documents/a. Projects/'+outputfolder

    
print, '++++++++++++++++++++++++++++'
print, '+ Start Importing Pyro Data +'
print, '++++++++++++++++++++++++++++'

print,''
print,'Folder: ',path    
    
; -------------------------------  
; import the data of all files in the folder and save in the storage folder as a .SAV file;
; -------------------------------

if file_search(path) ne '' then begin
  list_files = file_search(path+'/'+'*.txt') ; search all .txt files in folder
  n_files    = size(list_files,/n_elements)
  if n_files ne 0 then begin       ; start importing only if the file is non-zero
    
  ; Loop through all files  
  for i = 0, n_files-1 do begin

    ; Get experiment number and date from filename 
    fname = list_files[i]
    tmp_file = strsplit(fname, '/', /extract)
    n_tmp_file = n_elements(tmp_file)
    tmp_number = tmp_file[n_tmp_file-1]  
    tmp_file2 = strsplit(tmp_number, '.', /extract)
    n_tmp_file2 = n_elements(tmp_file2)
    shotname = tmp_file2[n_tmp_file2-2] 
    number = strsplit(shotname,'shot',/extract)
    date = tmp_file[n_tmp_file-2]
    
    ; import the data of the file    
    data_pyro = import_pyro_data(fname) 
    
    
    ; save the data of the file
    cd, filestore
    
    SAVE, /VARIABLES, FILENAME = 'pyro_'+string(date)+'_exp'+number+'.sav'
    
    print,'Saved file:        pyro_'+string(date)+'_exp'+number+'.sav'

  endfor
  endif
endif




end
