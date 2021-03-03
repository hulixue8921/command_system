#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     09/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import tkinter as tk;


class rollbackpage():
    def __init__(self, work):
        #work.updateWorkPage();
        work.work=tk.Frame(work.tk);
        work.work.pack();
        ####
        self.tk=work.tk;