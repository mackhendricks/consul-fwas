from flask import Flask, render_template, request, redirect, abort, flash,jsonify
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
   # services = getConsulServices("partnerA")
    partners = getPartnerInfo()
    pprint.pprint(partners)
    registerDefaultServices()
    addPartnerAccess("service2","access_partnerA")
    addPartnerAccess("service2","access_partnerB")
    addPartnerAccess("service2","access_partnerC")
    tags = getConsulServiceTags("service2")
    pprint.pprint(tags)
    #generateAccessRules("partnerA")
    all_services = getConsulServices()
    pprint.pprint(all_services)
    return render_template('fwaas.html', partners=settings.PARTNERS,available_services=all_services)

@app.route('/assignService')
def assignService():

    # Covert JSON message to Dictionary Object
    request_payload = getRequestData()

    partner = request_payload['partner']
    service = request_payload['service']

    addPartnerAccess("service","access_{}".format(partner))

@app.route('/deploy')
def deploy():

    response_payload = {}

    try:
        # Generate all access rules
        partners=settings.PARTNERS

        for partner in partners:
            generateAccessRules(partner)

        # Deploy access rules if partners exists
        #if partners is not None:
        #    deployAccessRules():

        response_payload['status'] = 1
        return jsonify(response_payload), 200
    
    except Exception as ex:
        print(ex)
        response_payload['status'] = 0
        return jsonify(response_payload), 400

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
        settings.ASA_HOST = os.getenv('ASA_HOST', settings.CONSUL_HOST)
        settings.CONSUL_HOST = os.getenv('CONSUL_HOST', settings.CONSUL_HOST)
        settings.CONSUL_PORT = os.getenv('CONSUL_PORT', settings.CONSUL_PORT)
        settings.APP_HOST = os.getenv('APP_HOST', settings.APP_HOST)
        settings.APP_PORT = os.getenv('APP_PORT', settings.APP_PORT)

        # configs depending on updated settings go here
        flask_app.env = "development" if settings.DEBUG else "production"
        flask_app.debug = settings.DEBUG

        app_manager = Manager(flask_app, with_default_commands=False)
        app_manager.add_command('runserver', CustomServer())
        app_manager.run()


    except Exception as ex:
        print(ex)

def teardown():
    pass


def registerDefaultServices():

    defaultServices = settings.DEFAULT_CONSUL_SERVICES

    for service in defaultServices:
        registerService(service)


def getConsulServiceTags(service):
    """ Returns a list of tags for a service. """
    try:
        c = consul.Consul(host=settings.CONSUL_HOST,port=settings.CONSUL_PORT)
        if c is not None:
            services = c.catalog.services()
            if services is not None:
                
                # Delete consul service from the services list
                del services[1]['consul']
                
                # Filter on the partner name
                #service = {k: v for (k, v) in services[1].items() if service in k}

            return services[1][service]
    except consul.ConsulException as ex:
        print(ex)


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

            # Delete consul service from the services list
            del services[1]['consul']

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

def registerService(service_name):
    
        c = consul.Consul(host=settings.CONSUL_HOST,port=settings.CONSUL_PORT)
        c.agent.service.register(service_name)

def addPartnerAccess(service_name, partner_name):
    """ Grant partner access to a service """

    c = consul.Consul(host=settings.CONSUL_HOST,port=settings.CONSUL_PORT)
    
    # Get Existing Tags
    currentTags = getConsulServiceTags(service_name)
    pprint.pprint(currentTags)
    if currentTags is not None:
        # Return if partner is already in the current tags
        for tag in currentTags:
            pprint.pprint(tag)
            pprint.pprint(str(partner_name).strip('[]').strip('\"'))
            if tag == str(partner_name):
                return
        currentTags.append(partner_name)
        newTags = currentTags
        pprint.pprint(newTags)
        c.agent.service.register(service_name, tags=newTags)
    else:
        c.agent.service.register(service_name, tags=list(partner_name))

def getPartnerIP(partner_name):
    """ Return the IP address of the partner """
    return settings.PARTNERS[partner_name]

def generateAccessRules(partner_name = None):
    """ Will generate terraform access rules for each partner """

    # Generate the main.tf file
    
    content = render_template('main_template.tf', asa_host=settings.ASA_HOST)
    filename = "{}/main.tf".format(settings.TF_RULE_DIR,partner_name)
    file = open(filename, 'w+')
    file.write(content)
    file.close()

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

        content = render_template('access_rule_template.tf', rules=rules,interface="management",partner_name=rule["partner_name"])
        filename = "{}/access_{}.tf".format(settings.TF_RULE_DIR,partner_name)
        file = open(filename, 'w+')
        file.write(content)
        file.close()

def deployAccessRules():
    """ Will use terraform to deploy the access rules """



if __name__ == "__main__":
    try:
        initApp(app)
    finally:
        teardown()
