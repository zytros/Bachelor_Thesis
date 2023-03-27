from http.server import BaseHTTPRequestHandler, HTTPServer
from PIL import Image
from PIL import ImageDraw
import io
import base64

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

file = open('objs/fitModel_Ctutc.obj', 'r')
obj = addUseMTL(file.read())
file.close()
file = open('objs/fitModel_Ctutc.mtl', 'r')
mtl = file.read()
file.close()
imgStr = ''
with open("objs/texture_Ctutc.png", "rb") as imageFile:
    imgf = imageFile.read()
    imgStr = base64.b64encode(imgf).decode('utf-8')
    
hostName = "localhost"
serverPort = 8080


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
        [identifier, imgNR] = self.headers['content-type'].replace('/', '').split('-')
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        byteList = post_data[1:-1].split(b', ')
        
        intList = [int(x) for x in byteList]
   
        # save image
        stream = io.BytesIO(bytes(intList))
        img = Image.open(stream)
        ImageDraw.Draw(img)
        img.save(identifier + imgNR +'.png', 'PNG')
        
        # send response
        self.wfile.write(bytes(str(len(intList)), "utf-8"))
        
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