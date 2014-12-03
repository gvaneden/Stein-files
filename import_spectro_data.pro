
function import_spectro_data, filedir, channel,frames

print,'++++++++++++++++++++++++++++++'
print,'+ Start Importing Spectra... +'
print,'++++++++++++++++++++++++++++++'


files = file_search(filedir+'/*.ROH')
filename = files[0]
if frames le 0 then frames = size(files,/n_elements)

ID_ADDR    =    1*4
ID_WIDTH   =    9*4
WL_ADDR    =   74*4
WL_WIDTH   =    5*4
TIME_ADDR  =   89*4
TIME_WIDTH =    1*4
DATA_ADDR  =  100*4
DATA_WIDTH = 2048*4 

length    = strlen(filename)
file_base = strmid(filename,0,length-8)
file_num  = uint(strmid(filename,length-8,length))  

current_file  = filename

i             = uint(0)
loaded_frames = uint(0)
timestamp_arr     = dblarr(frames)
c_time        = dblarr(frames)
wl_x          = dindgen(2048)
wavelength    = dblarr(2048)
intensity     = fltarr(2048,frames)


buffer  = read_binary(current_file)

while (file_info(current_file)).exists and loaded_frames lt frames do begin
  ;print, current_file
  buffer            = read_binary(current_file)

  serialnr          = string(byte(float(buffer(ID_ADDR  :ID_ADDR   + ID_WIDTH   - 1),0,ID_WIDTH   / 4)))
  if serialnr eq channel then begin
    if loaded_frames eq 0 then begin
      wl_coeff    = float(buffer(WL_ADDR  :WL_ADDR   + WL_WIDTH   - 1),0,WL_WIDTH   / 4) 
      wavelength  = wl_coeff(0) + wl_coeff(1) * wl_x + wl_coeff(2) * wl_x ^ 2 + wl_coeff(3) * wl_x ^ 3 + wl_coeff(4) * wl_x ^ 4  
    endif
    timestamp_float             = float(buffer(TIME_ADDR:TIME_ADDR + TIME_WIDTH - 1),0,TIME_WIDTH / 4)
    timestamp_arr(loaded_frames)    = double(timestamp_float)/double(100000); in seconds
    c_time(loaded_frames)       = double((file_info(current_file)).mtime) 
    intensity(*,loaded_frames)  = float(buffer(DATA_ADDR:DATA_ADDR + DATA_WIDTH - 1),0,DATA_WIDTH / 4)
    inttime                     = float(buffer(DATA_ADDR + DATA_WIDTH:DATA_ADDR + DATA_WIDTH + 3),0) ; in milliseconds
    loaded_frames ++
  endif 
  delvar,buffer
  i ++
  current_file = file_base + strtrim(string(i + file_num,format = '(i10.4)'),1) +'.ROH' 
endwhile

if loaded_frames ne 0 then begin
loaded_c_time    =    c_time(  0:loaded_frames-1)
loaded_timestamp = timestamp_arr(  0:loaded_frames-1)
loaded_intensity = intensity(*,0:loaded_frames-1)



print, ''
print, ' Filename(Start):     ',filename,format = '(a,a)'
print, ' Wavelength:          ',wavelength(0),'nm..',wavelength(2047),'nm',format = '(a,f6.2,a,f6.2,a)'
print, ' Number of Frames:  ',loaded_frames,format='(a,i5)'
print, ''

print, ' >>> Importing Spectra Done! <<<'
print, ''

return, create_struct('width',2048,'frames',loaded_frames,'inttime',inttime,'time',loaded_timestamp,$
                      'creation',loaded_c_time,'wavelength',wavelength,'data',loaded_intensity)
                      
endif

end