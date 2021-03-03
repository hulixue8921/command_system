#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     20/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import Th
a=Th.lock()

def f():
    a.acquire()
    print('11')
    #a.release()

Th.th(f).start()
Th.th(f).start()