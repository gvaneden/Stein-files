pro massinfo

element='Sn'

restore, unix_or_win('/home/emc/eden/Desktop/IDL/Evaporation flux_Tom/elemental_masses.sav')



mass_index = where(masses.field3 eq element)

mass = masses.field1[mass_index]

cgplot, masses.field1

print, mass


end