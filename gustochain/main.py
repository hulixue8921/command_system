# -------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      Administrator
#
# Created:     07/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
# ------------------------------------------------------------------------------


import tkinter
import tkinter.ttk as ttk
from Client import Client

root = tkinter.Tk()
tkinter.Label(text='运维中心', font='Arial 15').pack()
root.geometry('1400x500')

text_font = ('Arial', '13')
COLOR_1 = 'black'
COLOR_2 = 'white'
COLOR_3 = 'red'
COLOR_4 = '#2E2E2E'
COLOR_5 = '#8A4B08'
COLOR_6 = '#DF7401'
root.option_add('*TCombobox*Listbox.font', text_font)
s = ttk.Style()
s.configure('Treeview', rowheight=40, font='Arial 13')
s.configure('Treeview.Heading', rowheight=40, font='Arial 13')
s.configure("TButton", padding=3, relief="flat", font='Arial 10',
            background="#ccc")
s.configure("TLabel", font='Arial 13')
s.configure("TCombobox", font=('Courier New', '10'))

s.configure("TNotebook", borderwidth=0)
s.configure("TNotebook.Tab", foreground=COLOR_1, lightcolor=COLOR_6, borderwidth=50, font=('Courier New', '15'))

client = Client(host='10.31.4.40', port=8000, root=root)
client.run()
root.mainloop()
