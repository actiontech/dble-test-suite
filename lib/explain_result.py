class Explain:

    def __init__(self, result, context):

        self.context = context
        self.result = result
        self._types = self.get_types()
        self._nodes = self.get_datanode()
        self._sqlrefs = self.get_sqlref()

    def get_types(self):
        types = []
        for i in range(len(self.result)):
            types.append(self.result[i][1])
        return types

    def get_datanode(self):
        nodes = []
        for i in range(len(self.result)):
            nodes.append(self.result[i][0])
        return nodes

    def get_sqlref(self):
        sqlrefs = []
        for i in range(len(self.result)):
            sqlrefs.append(self.result[i][2])
        return sqlrefs

    def get_realsql(self):
        real_sql = []
        route_node = []
        for i in range(len(self._types)):
            if self._types[i] == "BASE SQL":
                real_sql.append(self._sqlrefs[i])
                route_node.append(self._nodes[i].split('.')[0])
        return real_sql, route_node

    def route_datanode(self):
        sql, datanode = self.get_realsql()
        route = list(set(datanode))
        route.sort(key=datanode.index)
        return route
