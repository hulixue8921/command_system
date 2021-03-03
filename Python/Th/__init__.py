import threading

def lock ():
    return threading.Lock();


class th(threading.Thread):
    def __init__(self , func):
        threading.Thread.__init__(self)
        self.func=func
        return
    def run(self):
        self.func()
        return
