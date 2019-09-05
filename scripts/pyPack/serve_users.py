from freeswitch import *

def xml_fetch( param1, param2 ):
    try:
        params_serialized = Event.serialize(param1).replace("\"", "")[:-2]
        params_dict = dict(item.split(":") for item in params_serialized.split("\n"))
     
        tvt = params_dict["X-TVT"]
        domain = params_dict["domain"].strip()
        user = params_dict["user"].strip()
        password = user
        vm_password = password
     
        consoleLog( "info", "===> User: %s \n" % user )
        consoleLog( "info", "     Domain: %s \n" % domain )
        consoleLog( "info", "     TVT: %s \n" % tvt )

        xml = """ <?xml version="1.0" encoding="UTF-8" standalone="no"?>
                        <document type="freeswitch/xml">
                            <section name="directory">
                                <domain name="%s">
                                    <user id="%s">
	                                <params>
	                                    <param name="password" value="%s"/>
	                                    <param name="vm-password" value="%s"/>
	                                </params>
                                    </user>
                                </domain>
                            </section>
                    </document> """ % (domain, user, password, vm_password)
        return xml
    except:
        return """ """

