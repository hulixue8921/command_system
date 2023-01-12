import tkinter.ttk as ttk
import tkinter
import sys
import operator

from gustoTk import gustoTk
from ConsPool import Connect
import threading
import functools
from tkinter import messagebox
import re
from ConsPool import Connect
from func_timeout import func_set_timeout


class k8sToplevel(gustoTk):
    def __init__(self, client, data):
        super().__init__(client)
        self.frame = None
        self.root = tkinter.Toplevel()
        self.root.geometry('1000x400')
        self.root.title(data)
        self.frames = []
        self.gcAarray = []
        self.ui()
        self.tagName = tkinter.StringVar()
        self.sourceData = data
        self.podNum = tkinter.IntVar()
        self.podNum.set(1)
        self.y = None
        return

    def ui(self):
        notebookTittle = ["ci/cd", "pod操作"]

        def clickNotebook(*args):
            i = notebook.index('current')
            print(notebookTittle[i])
            self.gc(self.gcAarray)
            frame = tkinter.Frame(self.frames[i])
            frame.pack(expand=True, pady=30)
            self.gcAarray.append(frame)
            funs = [functools.partial(cicdUi, frame), functools.partial(podUi, frame)]
            funs[i]()

            return

        def cicdUi(frame):
            def updateMessage(*args):
                data = args[0]
                self.y.forget()
                self.y.update()
                self.y.destroy()
                tag = self.tagName.get()
                for i in data['data']['data']:
                    if operator.eq(i['tagName'], tag):
                        message = i['tagMessage']
                        self.y = ttk.Label(frame, text=message)
                        self.y.grid(row=1, column=1, pady=10)
                        break
                return

            def get():
                apiData = {'modelName': 'gitlab', 'apiName': 'listTags',
                           'projectName': re.sub("-dev|-test|-pre|-prod", "", self.sourceData),
                           'token': self.client.token}
                data = Connect(()).sent(apiData).get()
                self.tagName.set("")
                tags = []
                if data['code'] == '200':
                    for i in data['data']['data']:
                        tags.append(i['tagName'])
                    tags.sort()
                    ttk.Label(frame, text="gitlabTag:").grid(row=0, column=0)
                    ttk.Label(frame, text="gitlabTagMessage:").grid(row=1, column=0)
                    x = ttk.Combobox(frame, textvariable=self.tagName, state="readonly", values=tags)
                    self.y = ttk.Label(frame, text="")
                    self.y.grid(row=1, column=1, pady=10)
                    x.bind("<<ComboboxSelected>>", functools.partial(updateMessage, data))
                    x.grid(row=0, column=1, pady=20)

                    ttk.Button(frame, text="提交", command=functools.partial(commit, data)).grid(row=2, columnspan=2,
                                                                                               pady=20)
                else:
                    messagebox.showinfo('info', data['data']['message'])

                return

            def commit(*args):
                data = args[0]
                env = None
                print(self.sourceData)
                if re.match('.*-dev$', self.sourceData):
                    env = "dev"
                elif re.match(".*-test", self.sourceData):
                    env = "test"
                elif re.match(".*-pre", self.sourceData):
                    env = "pre"
                elif re.match(".*-prod", self.sourceData):
                    env = "prod"
                else:
                    env = "prod"
                apiData = {'modelName': 'ci', 'apiName': 'fabu', 'env': env, 'git': data['data']['data'][0]['git'],
                           'tag': self.tagName.get(), 'token': self.client.token, 'service': self.sourceData}

                def get(service):
                    @func_set_timeout(180)
                    def ifTimeout():
                        data = Connect(()).sent(apiData).get()
                        if data['code'] == '200':
                            messagebox.showinfo('info', service + ": 发布成功！！！！")
                        elif data['code'] == '204':
                            self.reloadAgain()
                        else:
                            messagebox.showinfo('info', service + ": 发布失败，请联系管理员")

                    try:
                        ifTimeout()
                    except:
                        messagebox.showinfo('info', service + ": 发布超时，请联系上报给管理员")

                    return

                t1 = threading.Thread(target=functools.partial(get, self.sourceData))
                t1.start()

                self.root.destroy()
                return

            t1 = threading.Thread(target=get)
            t1.start()
            return

        def podUi(frame):
            def commitRestart():
                apiData = {"modelName": "k8s", "apiName": "restart", "service": self.sourceData,
                           "token": self.client.token}
                data = Connect(()).sent(apiData).get()
                if data['code'] == '200':
                    messagebox.showinfo('info', self.sourceData + " pod重启成功 ！！！！")
                elif data['code'] == '204':
                    self.reloadAgain()
                else:
                    messagebox.showinfo('info', self.sourceData + " pod重启失败，请联系管理员 ！！！！")

                self.root.destroy()

                return

            def commitPodNum():
                print(self.podNum.get(), self.sourceData)
                apiData = {"modelName": "k8s", "apiName": "podNum", "service": self.sourceData,
                           "number": self.podNum.get(), "token": self.client.token}
                data = Connect(()).sent(apiData).get()
                if data['code'] == '200':
                    messagebox.showinfo('info', self.sourceData + " pod 缩容或扩容成功 ！！！！")
                elif data['code'] == '204':
                    self.reloadAgain()
                else:
                    print(data)
                    messagebox.showinfo('info', self.sourceData + " pod 缩容或扩容失败，请联系管理员 ！！！！")

                self.root.destroy()
                return

            self.podNum.set(1)
            ttk.Label(frame, text="podNum:").grid(row=0, column=0, pady=40)
            ttk.Combobox(frame, textvariable=self.podNum, state="readonly", values=list(range(1, 10))).grid(row=0,
                                                                                                            column=1,
                                                                                                            padx=5)
            ttk.Button(frame, text="only重启", command=functools.partial(commitRestart)).grid(row=1, column=0)
            ttk.Button(frame, text="扩容或宿容", command=functools.partial(commitPodNum)).grid(row=1, column=1)

            return

        canvas = tkinter.Canvas(self.root)
        canvas.pack(expand=True, fill=tkinter.BOTH)
        self.frame = tkinter.Frame(canvas)
        self.frame.pack(expand=True, fill=tkinter.BOTH)
        notebook = ttk.Notebook(self.frame, style='TNotebook')
        notebook.bind("<<NotebookTabChanged>>", clickNotebook)
        for i, j in enumerate(notebookTittle):
            self.frames.append(tkinter.Frame(notebook))
            notebook.add(self.frames[-1], text=j, compound=tkinter.TOP)
        notebook.pack(fill=tkinter.BOTH)

        return
