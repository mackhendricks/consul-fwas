from flask import Flask, render_template, request, redirect, abort, flash
from flask_script import Manager, Server
import settings, pprint, os
import consul

app = Flask(__name__, static_folder="./static", static_url_path="/static")

class CustomServer(Server):
    """ Customize the Flask server with our settings """

    def __init__(self):
        super().__init__(
            host=settings.APP_HOST,
            port=settings.APP_PORT
        )


@app.route('/')
def index():
    services = getConsulServices("partnerA")
    pprint.pprint(services)
    partners = getPartnerInfo()
    pprint.pprint(partners)
    addPartnerAccess("service2",["access_partnerA"])
    generateAccessRules("partnerA")
    return render_template('faas.html')

def imgFilter(name):
    images_url = urllib.parse.urljoin(app.static_url_path, 'images')
    search_path = os.path.join(app.static_folder, 'images', name)
    filenames = glob.glob(search_path + '.*')
    if len(filenames) > 0:
        return urllib.parse.urljoin(images_url, filenames[0])
    else:
        return ""

def initApp(flask_app):
    # Flask App Manager configs
    try:

        # Customer Jinga filters

        flask_app.jinja_env.filters["imgFilter"] = imgFilter

        # Overvide settings if Environment settings are defined
        settings.CONSUL_HOST = os.getenv('CONSUL_HOST', settings.CONSUL_HOST)
        settings.CONSUL_PORT = os.getenv('CONSUL_HOST', settings.CONSUL_PORT)


        app_manager = Manager(flask_app, with_default_commands=False)
        app_manager.add_command('runserver', CustomServer())
        app_manager.run()

        if settings.DEBUG == True:
            self.use_debugger = True
            self.use_reloader = True
        else:
            self.use_debugger = None
            self.use_reloader = None
            self.threaded = True
            self.processes = 1

    except Exception as ex:
        print(ex)

def teardown():
    pass

def getConsulServices(partner=None):
    """ Returns a list of services. Only returns the services assigned to a partner if the partner name is provided """
    try:    
        c = consul.Consul(host=settings.CONSUL_HOST,port=settings.CONSUL_PORT)
        if c is not None:
            services = c.catalog.services()
            if services and partner is not None:
                # Filter on the partner name
                services = {k: v for (k, v) in services[1].items() if "access_{}".format(partner) in v}
                return services
            return services[1]
    except consul.ConsulException as ex:
        print(ex)


def getConsulNodes(service=None):
    """ Returns the ip/port of nodes that contains the service """
    
    targets = []
    c = consul.Consul(host=settings.CONSUL_HOST,port=settings.CONSUL_PORT)
    nodes = c.catalog.service(service)
    for node in nodes[1]:
        target_info = {}
        target_info["ip"] = node["Address"]
        target_info["port"] = node["ServicePort"]
        targets.append(target_info)
    
    pprint.pprint(targets)
    return targets



def getPartnerInfo():

    return settings.PARTNERS


def addPartnerAccess(service_name, partner_name):
    """ Grant partner access to a service """

    c = consul.Consul(host=settings.CONSUL_HOST,port=settings.CONSUL_PORT)
    c.agent.service.register(service_name, tags=partner_name)

def getPartnerIP(partner_name):
    """ Return the IP address of the partner """
    return settings.PARTNERS[partner_name]

def generateAccessRules(partner_name = None):
    """ Will generate terraform access rules for each partner """

    partner_services = getConsulServices(partner_name)
    rules = []
    for service in partner_services:
        for node in getConsulNodes(service):
            rule={}
            rule["partner_name"] = partner_name
            rule["source_ip"] = getPartnerIP(partner_name)
            rule["destination_ip"] = node["ip"]
            rule["service_port"] = node["port"]
            rules.append(rule)

        content = render_template('access_rule.tf', rules=rules,interface="management",partner_name=rule["partner_name"])
        filename = "{}/access_{}.tf".format(settings.TF_RULE_DIR,partner_name) 
        file = open(filename, 'w')
        file.write(content)
        file.close()

def deployAccessRules():
    """ Will use terraform to deploy the access rules """



if __name__ == "__main__":
    try:
        initApp(app)
    finally:
        teardown()
