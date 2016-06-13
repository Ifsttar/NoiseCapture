import requests
import getpass
import httplib
import base64

filecontent = open("geoserver/src/test/resources/org/noise_planet/noisecapturegs/track_f7ff7498-ddfd-46a3-ab17-36a96c01ba1b.zip", 'rb').read()
zipContent = base64.b64encode(filecontent)

xml_data = """<?xml version="1.0" encoding="UTF-8"?><wps:Execute version="1.0.0" service="WPS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.opengis.net/wps/1.0.0" xmlns:wfs="http://www.opengis.net/wfs" xmlns:wps="http://www.opengis.net/wps/1.0.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wcs="http://www.opengis.net/wcs/1.1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/wps/1.0.0 http://schemas.opengis.net/wps/1.0.0/wpsAll.xsd">
  <ows:Identifier>groovy:nc_upload</ows:Identifier>
  <wps:DataInputs>
    <wps:Input>
      <ows:Identifier>encode64ZIP</ows:Identifier>
      <wps:Data>
        <wps:LiteralData>"""+zipContent+"""</wps:LiteralData>
      </wps:Data>
    </wps:Input>
  </wps:DataInputs>
  <wps:ResponseForm>
    <wps:RawDataOutput>
      <ows:Identifier>result</ows:Identifier>
    </wps:RawDataOutput>
  </wps:ResponseForm>
</wps:Execute>"""

print len(filecontent), " octets"

def main():
	proxies = {
	  'http': 'http://137.121.61.4:3128',
	  'https': 'http://137.121.1.26:3128',
	}

	resp = requests.post('http://onomap-gs.noise-planet.org/geoserver/ows?service=wps&version=1.0.0&request=Execute',
	data = xml_data,
	proxies=proxies)
	
	if resp.status_code != 200:
		# This means something went wrong.
		raise Exception(httplib.responses[resp.status_code])
	else:
		print resp.content
	
main()