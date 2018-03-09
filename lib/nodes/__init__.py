from random import sample
import paramiko
from lib.ssh import SSHClient, SFTPClient
from lib.log import Logging


class Node(Logging):
    def __init__(self, ip, ssh_user, ssh_password, host_name=None):
        super(Node, self).__init__()
        self._ip = ip
        self._ssh_user = ssh_user
        self._ssh_password = ssh_password
        self._host_name = host_name
        self.connection = None
        self.sftp_connection = None
        self.components = set()
        self.instances = set()
        self._is_ports = False
        self._server_id = ''
        self.logger.debug('create node ip <{0}> ssh_user <{1}> '
                          'ssh_password <{2}> host_name <{3}>'.format(self.ip, self.ssh_user, self.ssh_password,
                                                                      self.host_name))
    def get_connection(self):
        if self.connection is None:
            self.connection = SSHClient(self.ip, self.ssh_user, self.ssh_password)
            self.connection.connect()
        return self.connection

    def get_sftp_connection(self):
        if self.sftp_connection is None:
            port = '22'
            self.sftp_connection = SFTPClient(self.ip, self.ssh_user, self.ssh_password, int(port))
            self.sftp_connection.sftp_connect()
        return self.sftp_connection

    def register_component(self, component):
        self.logger.debug('node <{0}> register component <{1}>'.format(self.ip, component.component_type))
        self.components.add(component)

    def unregister_component(self, component):
        if component in self.components:
            self.logger.debug('node <{0}> unregister component <{1}>'.format(self.ip, component.component_type))
            self.components.remove(component)

    def register_instance(self, instance):
        self.logger.debug('node <{0}> register instance <{1}>'.format(self.ip, instance.instance_info['mysql_id']))
        self.instances.add(instance)

    def unregister_instance(self, instance):
        if instance in self.instances:
            self.logger.debug(
                'node <{0}> unregister instance <{1}>'.format(self.ip, instance.instance_info['mysql_id']))
            self.instances.remove(instance)

    @property
    def ip(self):
        return self._ip

    @ip.setter
    def ip(self, value):
        self._ip = value

    @property
    def ssh_user(self):
        return self._ssh_user

    @ssh_user.setter
    def ssh_user(self, value):
        self._ssh_user = value

    @property
    def ssh_password(self):
        return self._ssh_password

    @ssh_password.setter
    def ssh_password(self, value):
        self._ssh_password = value

    @property
    def host_name(self):
        return self._host_name

    @host_name.setter
    def host_name(self, value):
        self._host_name = value

    @property
    def is_ports(self):
        return self._is_ports

    @is_ports.setter
    def is_ports(self, value):
        self._is_ports = value

    @property
    def server_id(self):
        return self._server_id

    @server_id.setter
    def server_id(self, value):
        self._server_id = value

class Nodes(Logging):
    def __init__(self, nodes=None):
        super(Nodes, self).__init__()
        if nodes is None:
            self.nodes = []
        else:
            self.nodes = nodes

    def add_node(self, node):
        self.nodes.append(node)

    def remove_node(self, node):
        if node in self.nodes:
            self.nodes.remove(node)
        else:
            self.logger.warning('No such node in nodes!')

    def get_nodes_is_ports(self):
        nodes = []
        for node in self.nodes:
            if node.is_ports:
                nodes.append(node)
        return nodes

    def get_nodes_has_component(self, component_type):
        nodes = []
        for node in self.nodes:
            for component in node.components:
                if component.component_type == component_type:
                    nodes.append(node)
                    break
        return nodes

    def get_components(self, component_type):
        components = []
        for node in self.nodes:
            for component in node.components:
                if component.component_type == component_type:
                    components.append(component)
        return components

    def get_all_components(self):
        components = []
        for node in self.nodes:
            for component in node.components:
                components.append(component)
        return components

    def get_servers(self):
        server_nodes = []
        no_server_nodes = []
        for node in self.nodes:
            for component in node.components:
                if component.component_type == 'uagent':
                    server_nodes.append(node)
                    break
            else:
                no_server_nodes.append(node)
        return server_nodes, no_server_nodes

    def get_nodes_registered_component(self, component_type):
        registered_nodes = []
        unregistered_nodes = []
        for node in self.nodes:
            for component in node.components:
                if component.component_type == component_type:
                    registered_nodes.append(node)
                    break
            else:
                unregistered_nodes.append(node)
        return registered_nodes, unregistered_nodes

    def get_nodes_registered_components(self, component_type_list):
        registered_nodes = []
        unregistered_nodes = []
        for node in self.nodes:
            for component in node.components:
                for component_type in component_type_list:
                    if component.component_type == component_type:
                        registered_nodes.append(node)
                        break
                else:
                    continue
                break
            else:
                unregistered_nodes.append(node)
        return registered_nodes, unregistered_nodes

    def get_random_nodes(self, num=1):
        return sample(self.nodes, num)

    def get_server_by_id(self, server_id):
        server_nodes, no_server_nodes = self.get_servers()

        for server_node in server_nodes:
            if server_node.server_id == server_id:
                return server_node
        else:
            return None

    def get_node_by_host_name(self, host_name):
        for node in self.nodes:
            if node.host_name == host_name:
                return node
        return None
