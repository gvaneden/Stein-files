

function import_seq, filename, do_crop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;2013-03-19 Dirk van den Bekerom
;
;This IDL-routine opens a .seq/.fcf file and reads digital level data and timestamps into IDL arrays.
;To start off, the program might look a but obfuscated. This is because the chunks of data were tracked 
;down in the binary files manually, without the use of library routines or SDK's (which cost lots of $$$).
;What makes things worse is that there are actually two different kinds of .seq files, and two kinds of 
;.fcf files (of which, one pair of .seq and .fcf is identical in terms of data location within the file)
;This motivates to make a distinction between three file-'types': 
;- 'old'    being .SEQ files recorded with ThermaCAM Researcher Pro
;- 'old_ex' being originally 'old'-category files, but were exported to .fcf using FLIR ResearchIR MAX
;- 'new'    being files recorded in FLIR ResearchIR directly, this can be either .seq or .fcf
;So how to tell which is which? 'old' and 'old_ext' have the same frame sizes, but 'new' a different one.
;By modulating the total filesize with the frame size, we can distinguish between 'old'&'old_ex' or 'new'.
;The 'old_ex' has an extra header which the 'old' doesn't have, so if the modulated size is zero it's an
;'old', if it is non-zero (0xB3D in all cases) it is an 'old_ex'.
;Determining what file we are looking at is crucial, because the data is stored at different locations in 
;the different files.
;However, you don't have to worry about this because the program does it all for you :)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print,'+++++++++++++++++++++++++'
print,'+   Starting IR-import  +'
print,'+++++++++++++++++++++++++'



;Whether or not to use the same frame that was used during recording (1), or to get the entire frame (0).
;This is currently an argument to the import function.
;do_crop  = 1       ;toggle cropping
;filename = '/Rijnh/Shares/Projects/Pilot/Measurement Data/IR Camera/2013/2013-02-28/q0010.SEQ'

image_width  = 640 ;the original image_width  (fixed) 
image_height = 480 ;the original image_height (fixed)

;adresses of important data in the .seq/.fcf file
DATA_WIDTH          = '96000'x   ;the width of the data in bytes ( = 640 x 480 x 2 byte)

OLD_EMISSIV_ADDR    =    'E0'x   ;emissivity set in software
OLD_FILTER_ADDR     =   '153'x   ;filter-ID byte: [filter1 = 0x43; filter2 = 0x44; filter3 = 0x45]
OLD_SCALE_ADDR      =   '42C'x   ;zoom factor
OLD_TIME_ADDR       =   '444'x   ;timestamp
OLD_DATA_ADDR       =   '55C'x   ;the actual data
OLD_FRAME_WIDTH     = '97490'x   ;size in bytes of one frame

OLD_EX_EMISSIV_ADDR = '97340'x   ;emissivity set in software
OLD_EX_FILTER_ADDR  = '96553'x   ;filter-ID
OLD_EX_SCALE_ADDR   = '9768C'x   ;zoom factor
OLD_EX_TIME_ADDR    =   'A9C'x   ;timestamp
OLD_EX_DATA_ADDR    =   'BB4'x   ;the actual data
OLD_EX_FRAME_WIDTH  = '97490'x   ;size in bytes of one frame
OLD_EX_TIME_1_ADDR  = '976A4'x   ;timestamp of the first frame
OLD_EX_DATA_1_ADDR  =   '420'x   ;data of the first frame

NEW_EMISSIV_ADDR    = 'AC574'x   ;emissivity set in software
NEW_FILTER_ADDR     = 'AC5E7'x   ;filter-ID
NEW_SCALE_ADDR      = 'AC5B4'x   ;zoom factor (might not work properly for 'new' type files)
NEW_TIME_ADDR       = '16C04'x   ;timestamp
NEW_DATA_ADDR       = '1721C'x   ;the actual data
NEW_FRAME_WIDTH     = '96A1C'x   ;size in bytes of one frame
NEW_TIME_1_ADDR     = 'AC8D8'x   ;timestamp of the first frame
NEW_DATA_1_ADDR     = '16554'x   ;data of the first frame

;read the file
buffer = read_binary(filename) ;reads the entire .seq file (binary) into one big variable

;check what filetype we're dealing with
buffer_size     = size(buffer,/n_elements)         ;get the size in bytes of the buffer
non_frame_bytes = buffer_size mod OLD_FRAME_WIDTH  ;calculate the amount of bytes that do not belong to a frame

case non_frame_bytes of  
  '0'x: begin                         ;If there is no header, it is an 'old' file.
    filetype    = 'old'               ;Set filetype to 'old'
    EMISSIV_ADDR = OLD_EMISSIV_ADDR
    FILTER_ADDR  = OLD_FILTER_ADDR
    SCALE_ADDR   = OLD_SCALE_ADDR
    TIME_ADDR    = OLD_TIME_ADDR     
    DATA_ADDR    = OLD_DATA_ADDR
    FRAME_WIDTH  = OLD_FRAME_WIDTH
    end
  'B3D'x: begin                       ;The 'non-frame' bytes belong to the header. If it is exactly 0xB3D, then it is an 'old_ex' file.
    filetype     = 'old_ex'            ;Set filetype to 'old_ex'
    EMISSIV_ADDR = OLD_EX_EMISSIV_ADDR
    FILTER_ADDR  = OLD_EX_FILTER_ADDR
    SCALE_ADDR   = OLD_EX_SCALE_ADDR
    TIME_ADDR    = OLD_EX_TIME_ADDR    
    DATA_ADDR    = OLD_EX_DATA_ADDR
    FRAME_WIDTH  = OLD_EX_FRAME_WIDTH
    end
  else: begin
    filetype    = 'new'                                  ;If there is a header, but of a different size, it is assumed a 'new' type.
    non_frame_bytes = buffer_size mod NEW_FRAME_WIDTH    ;'new' Types have a different frame width so NFB needs to be recalculated.
    EMISSIV_ADDR = NEW_EMISSIV_ADDR                      ;Note that all files that are corrupted or not of a valid type also fall in
    FILTER_ADDR  = NEW_FILTER_ADDR                       ;this category.
    SCALE_ADDR   = NEW_SCALE_ADDR                       
    TIME_ADDR    = NEW_TIME_ADDR                         
    DATA_ADDR    = NEW_DATA_ADDR
    FRAME_WIDTH  = NEW_FRAME_WIDTH 
  end
endcase

num_frames = uint((buffer_size - non_frame_bytes)/FRAME_WIDTH) ;calculate the amount of frames
filter     = buffer(FILTER_ADDR) - '42'x                       ;filter ID: [1 = filter1, 2 = filter2, 3 = filter3]

emissivity = float(buffer(EMISSIV_ADDR:EMISSIV_ADDR + 3),0)

if do_crop then begin
  scale          = float(buffer(SCALE_ADDR    :SCALE_ADDR + 3),0)
  delta_center_x =   fix(buffer(SCALE_ADDR + 4:SCALE_ADDR + 5),0)
  delta_center_y =   fix(buffer(SCALE_ADDR + 6:SCALE_ADDR + 7),0) 
endif else begin
  scale          = float(1.0)
  delta_center_x =   fix(0)
  delta_center_y =   fix(0)
endelse

crop_half_width  =  round(image_width  / (2 * scale))         ;width  of the crop
crop_half_height =  round(image_height / (2 * scale))         ;height of the crop

crop_width  = 2 * crop_half_width
crop_height = 2 * crop_half_height

crop_center_x = round(image_width / 2) + delta_center_x   ;center-x of the crop. round() is there for compatibility
crop_center_y = round(image_height/ 2) - delta_center_y   ;center-y of the crop

crop_left    = uint(crop_center_x - crop_half_width)
crop_right   = uint(crop_center_x + crop_half_width)  - 1
crop_bottom  = uint(crop_center_y - crop_half_height)   
crop_top     = uint(crop_center_y + crop_half_height) - 1

window, 1, xpos = 250, ypos = 150, xsize = crop_width, ysize = crop_height

;oVid = IDLffVideoWrite(filename+'_1.mp4')
;vidStream = oVid.AddVideoStream(crop_width, crop_height, 25)
;vidframe = bytarr(3,crop_width,crop_height)

print, ''                                          ;print some of our data
print, ' Filename: ',               filename,        format = '(a,a)'
print, ' Non-frame bytes:  ',       non_frame_bytes, format = '(a,i8)'
print, ' Determined filetype: "',   filetype,'"',    format = '(a,a,a)' 
print, ' Number of frames:     ',   num_frames,      format = '(a,i4)'
print, ' Filter type:             ',filter,          format = '(a,i1)'
print, ' Emissivity:         ',     emissivity,      format = '(a,f6.4)'
print, ' Scale:                ',   scale,           format = '(a,f4.2)'
print, ' Center:             (',    crop_center_x,',',crop_center_y,')', format = '(a,i3,a,i3,a)'
print, ' From (',crop_left,',',crop_bottom,') to (',crop_right,',',crop_top,');',format='(a,i3,a,i3,a,i3,a,i3,a)'
print, ''

time = dblarr(num_frames)     ;initialize time array
data = dblarr(crop_width,crop_height,num_frames) 

;entering main loop

for i=0, num_frames-1 do begin
  if i eq 0 and filetype ne 'old' then begin  ;'old_ex' and 'new' have a different first frame.   
    case filetype of  
      'old_ex': begin ;if filetype is 'old_ex'
        time_bytes  = buffer(OLD_EX_TIME_1_ADDR:OLD_EX_TIME_1_ADDR + 5)         ;read the time data (sec.) in bytes
        data_bytes  = buffer(OLD_EX_DATA_1_ADDR:OLD_EX_DATA_1_ADDR + DATA_WIDTH);read the data of the first frame in bytes     
      end
      'new':    begin ;if filetype is 'new'
        time_bytes  = buffer(NEW_TIME_1_ADDR:NEW_TIME_1_ADDR + 5)               ;read the time data (sec.) in bytes
        data_bytes  = buffer(NEW_DATA_1_ADDR:NEW_DATA_1_ADDR + DATA_WIDTH)      ;read the data of the first frame in bytes    
      end
      else:     begin ;if the filetype is neither 'old', 'old_ex' or 'new' (not possible, but just in case): fill with zeros
        time_bytes  = bytarr(6)
        data_bytes  = bytarr(DATA_WIDTH)     
      end
    endcase
  endif else begin
    time_bytes    = buffer(TIME_ADDR + i * FRAME_WIDTH:TIME_ADDR + 5 + i * FRAME_WIDTH)             ;read the time data (sec.) in bytes
    data_bytes    = buffer(DATA_ADDR + i * FRAME_WIDTH:DATA_ADDR + DATA_WIDTH - 1 + i * FRAME_WIDTH);read the data of the i'th frame in bytes
  endelse
   
  time_s  =   (long(time_bytes(0:3),0)) mod (60 * 60 * 24);combine four bytes into long 
  time_ms =    fix(time_bytes(4:5),0)               ;combine two bytes into int 
  time(i) = double(time_s) + double(time_ms)/1000   ;combine sec. and msec. into one double representing timestamp in seconds
  
  data_int       = uint(data_bytes,0,DATA_WIDTH/2)                           ;combine each two bytes to make an int
  data_uncropped = rotate(reform(double(data_int),image_width,image_height),7)         ;reform the int's into the image array                                     
  data(*,*,i)    = data_uncropped(crop_left:crop_right,crop_bottom:crop_top) ;crop the data

  
  ;print,'Frame:', i+1, '/', num_frames,'    Timestamp: ',time(i), format ='(a,i3,a,i3,a,f14.3)' ;print timestamp
  
  if i ne 0 then tvscl, data(*,*,i)-data(*,*,0)       ;show the image
  ;wait,0.04
;  vidframe(0,*,*) = byte(((data(*,*,i)-min(data(*,*,i)))/float(max(data(*,*,i))-min(data(*,*,i))))*'FF'x)
;  vidframe(1,*,*) = vidframe(0,*,*)
;  vidframe(2,*,*) = vidframe(0,*,*)
;  frame_time = oVid.Put(vidStream, vidframe)
  
endfor
buffer = 0

;oVid.Cleanup

print,' >>> Importing IR-Data Done! <<<'
print,''

return, create_struct('width',crop_width,'height',crop_height,'frames',num_frames,'time',time,'data',data,'filter',filter,'emissivity',emissivity)

end

