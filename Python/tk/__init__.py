#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     08/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------

from . import Pages;
import tkinter

class tk (tkinter.Tk):
    def __init__ (self, con):
        super().__init__();
        self.geometry('1000x400')
        tkinter.Label(text='运维中心',font='Arial 15').pack();
        self.con=con
        Pages.index.Index(self);
        return

    def workPage(self):
        self.workpage=Pages.work.WorkPage(self);