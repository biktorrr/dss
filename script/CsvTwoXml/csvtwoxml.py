#! /usr/bin/env python
# CSV to XML converter
# Victor de Boer 2013

import csv

csv.register_dialect('custom',
                     delimiter=',',
                     doublequote=True,
                     escapechar=None,
                     quotechar='"',
                     quoting=csv.QUOTE_MINIMAL,
                     skipinitialspace=False)

# maximum number of rows before new file is started
maxrows = 50000

# counters
currow= 0
curfile = 0

# first file
f = open('opvarenden_'+str(curfile)+'.xml', 'w')

# input file name
with open('voc_opvarenden.csv') as ifile:
    rownum = 0
    data = csv.reader(ifile, delimiter=';', dialect='custom') # register different delimiter here
    f.write('<?xml version="1.0" encoding="iso-8859-1"?>\n')
    f.write("<document>\n")
    for record in data:

        if (rownum ==0):
            header = record

        else:
            try:
                colnum = 0
                f.write("   <record>\n")
                for col in record:
                   # mycol = str(col.encode('utf-8','strict'))
                    f.write( "      <"+header[colnum]+">" + col  + "</"+header[colnum]+">\n")
                    colnum += 1
                f.write("   </record>\n")
            except IndexError:
                print(rownum)
                
        rownum += 1
        currow += 1 
        f.flush

        # If maxrows is reached, start a new file
        if (currow == maxrows):
            
            f.write("</document>")
            f.flush
            f.close
            curfile +=1
            currow = 0
            f = open('opvarenden_'+str(curfile)+'.xml', 'w')
            f.write('<?xml version="1.0" encoding="iso-8859-1"?>\n')
            f.write("<document>\n")

    f.write("</document>")
    f.close()
    
    
