class Exporter:
    def __init__(self, config):
        self.config = config
        self.name = "dummy"
        self.tables = {}
    
    def line(self, text="", indent = 0):
        return '\t' * indent + text + "\n"
    
    def parse_tabels(self, tabels):
        pass
    
    def dump(self):
        pass