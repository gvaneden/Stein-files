; Simple program to pick a data point from a 2D array using cursor


function point_select, data,                     $  ; data to be processed
                       winsize = winsize            ; if set can add own winsize of form [xsize,ysize]
                       
if not keyword_set(winsize) then winsize = [800,800]

window, xsize = winsize[0], ysize = winsize[1]

loadct, 34

contour, data,/fill, nlevels = 15    ,/iso

iflag = 0

xpos= fltarr(1)
ypos= fltarr(1)

while (iflag eq 0 ) do begin

  print,'select a point on the contour plot - when happy click right mouse to finish'
  cursor,x1,y1,/down,/data
  if (!mouse.button eq 4 ) then iflag = 1 else begin
  
    print, 'x = ',round(x1),' y =  ',round(y1),' Data value: ',data[round(x1),round(y1)]
    xpos = [xpos,x1]
    ypos = [ypos,y1]
  endelse
endwhile



x  = round(xpos[n_elements(xpos)-1])
y  = round(ypos[n_elements(ypos)-1])
z  = data[x,y]

ret  = {x:x, y:y, z:z} 

return, ret

end