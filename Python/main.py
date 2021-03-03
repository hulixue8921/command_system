#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      Administrator
#
# Created:     07/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#------------------------------------------------------------------------------


import struct
import operator
import ConsPool;
import tk;


class  client ():
    def __init__(self,**args):
        self.args=args
        self.con=ConsPool.createCons((self.args['host'],self.args['port']));
        self.tk=tk.tk(self.con);
        self.start();
        return
    def start (self):
        self.tk.mainloop()
        return


c=client(host='172.23.3.247' , port=8000);












