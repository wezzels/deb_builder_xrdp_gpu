### DISA STIGS standards are distributed in XML and XSLT file pairs.  Under IE, it was possible to open the XSLT and then open the XML, where the latter 
### would be properly formatted.  With IE no longer in use, this script can generate the html from a pair.
### TODO: Automate so that it generates for all entries in the archived zip (zip of zips)
### -----------------------------------------------------------------------------------------------------

from lxml import etree
path_xml = 'U_MS_Windows_10_STIG_V2R3_Manual-xccdf.xml'
path_xslt = 'STIG_unclass.xsl'
dom = etree.parse(path_xml)
xslt =etree.parse(path_xslt)
transform = etree.XSLT(xslt)
newdom = transform(dom)
s = etree.tostring(newdom, pretty_print=True)
with open('output.html', 'w') as fout:
	fout.write("".join(chr(c) for c in s))
