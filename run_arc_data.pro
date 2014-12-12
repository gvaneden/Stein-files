pro run_arc_data

; *****************************************************************          
; This program imports all arc data (.xls files) of a specific folder              
; and saves them in the path specified            
; 
; Created by:
; D.U.B. Aussems - 10-11-2014
;                                                                 
; *****************************************************************            


; ------------------
; set path and date ;
; ------------------

start_path = '/Rijnh/Shares/Projects/Pilot/Measurement Data/Cascaded Arc/'
year= '2014'
month='11'
date = '2014-11-18'
path = start_path+year+'/'+year+'-'+month+'/'+date+'/'

outputfolder= '11-2014 Sn exposure Pilot/processed data/cascaded arc'
filestore = '/home/emc/eden/My Documents/a. Projects/'+outputfolder


print, '++++++++++++++++++++++++++++'
print, '+ Start Importing Arc Data +'
print, '++++++++++++++++++++++++++++'

print,''
print,'Folder: ',path
     
; -------------------------------  
; import the data of all files in the folder ;
; -------------------------------
;       
      if file_search(path) ne '' then begin
        list_files = file_search(path+'*.xls')  ; search all .xls files in folder
           
        n_files    = size(list_files,/n_elements) 
        for i = 0, n_files-1 do begin
          fname = list_files[i]  
          if file_search(fname(0)) ne '' then begin ; start importing only if the file is non-zero
             import = import_arc_data(fname,-1,filestore)
           endif
        endfor
      endif



end
