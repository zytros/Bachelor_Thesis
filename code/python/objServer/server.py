from http.server import BaseHTTPRequestHandler, HTTPServer
from PIL import Image
from PIL import ImageDraw
import io
import json
import base64
import os

def addUseMTL(obj):
    lines = obj.split('\n')
    for l in lines:
        if l.startswith('usemtl'):
            return obj
    for i in range(len(lines)):
        if lines[i].startswith('f '):
            lines.insert(i, 'usemtl myMaterial')
            break
    return '\n'.join(lines)

def checkUseMTL(obj):
    lines = obj.split('\n')
    for l in lines:
        if l.startswith('usemtl'):
            return True
    return False

file = open('objs/fitModel_Demo_Augmentation.obj', 'r')
obj = addUseMTL(file.read())
file.close()
file = open('objs/fitModel_Demo_Augmentation.mtl', 'r')
mtl = file.read()
file.close()
imgStr = ''
with open("objs/texture_Demo_Augmentation.png", "rb") as imageFile:
    imgf = imageFile.read()
    imgStr = base64.b64encode(imgf).decode('utf-8')
    
hostName = "localhost"
serverPort = 8080

def saveImg(img, ident, imgNR):
    if os.path.exists(ident) == False:
        os.makedirs(ident)
    stream = io.BytesIO(bytes(img))
    img = Image.open(stream)
    ImageDraw.Draw(img)
    img.save(ident + '/' + imgNR +'.png', 'PNG')


class MyServer(BaseHTTPRequestHandler):        
    def do_GET(self):
        
        # set headers
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        
        
        # set response
        function = self.headers['content-type']
        response = ''
        if function == 'getObj':
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            response = obj
            print(checkUseMTL(obj))
            self.wfile.write(bytes(response, "utf-8"))
        elif function == 'getMtl':
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            response = mtl
            self.wfile.write(bytes(response, "utf-8"))
        elif function == 'getImg':
            self.send_header("Content-type", "text/plain")
            response = imgStr
            self.end_headers()
            self.wfile.write(bytes(response, "utf-8"))
            print(len(imgStr))
        
    
    def do_POST(self):
        
        # set headers
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        
        # get data
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        string = post_data.decode('utf-8')
        dictionary = json.loads(string)
        
        saveImg(dictionary['img1'], dictionary['identifier'], 'img1')
        saveImg(dictionary['img2'], dictionary['identifier'], 'img2')
        saveImg(dictionary['img3'], dictionary['identifier'], 'img3')
        file = open(dictionary['identifier'] + '/params.txt', 'w+')
        file.write(str(dictionary['nippleDist']) + '\n')
        
        self.wfile.write(bytes('response', "utf-8"))
        
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, PUT, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

if __name__ == "__main__":        
    webServer = HTTPServer((hostName, serverPort), MyServer)
    print("Server started http://%s:%s" % (hostName, serverPort))
    
    try:
        webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    webServer.server_close()
    print("Server stopped.")