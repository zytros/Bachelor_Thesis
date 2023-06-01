This is a short description on how to use the prototype and where to find what

1. Use the prototype:
    - open folder "servers"
    - open folder "objServer"
    - run start.bat
    - go back, open the folder "FlutterServer"
    - run start.bat
    - go to browser, open "localhost:8000/"
    - allow the application to use your webcam, and wait a few seconds until all is loaded
    
Note: the object server runs on port 28080, and the web application on port 8000. If you want to change the port of the object server you need to change the url in the file "code/flutterTest/WebApp/lib/home_page.dart" on line 22 and recompile the project according to 2. Further you need to change the serverPort on line 41 in the file "servers/objServer/server.py" to the same port from above. 
If you want to change the port of the web application you need to change the last number of the file "servers/FlutterServer/start.bat" to whatever you want.

2. Compiling the web application:
    - navigate to the folder the project is in
    - first type the command in terminal "flutter clean" then "flutter build web"
    - inside the build folder navigate into the web folder
    - copy all the files into the FlutterServer folder
    - inside the index.html on line 27 change "icons/Icon-192.png" to "./icons/Icon-192.png" and on line 40 change "flutter.js" to "./flutter.js"
    - navigate into "servers/FlutterServer/assets/assets"
    - copy the "breast_indices" folder, "eigVecs.csv" and "mean.txt" files into "servers/FlutterServer/assets"
    - you are ready to run

3. My folder structure:
    - servers: here are the servers for running the application as described in 1.
    - code: here is all my code
        - flutter: here is my flutter code
            - WebApp: this is my application, all the interesting stuff you can find in the folder lib
        - python: here is my python code
            - nonlinearOptimizer: this is the code I used for the L-BFGS-B algorithm
            - objServer: this is the code used for the backend server
            - pca: this is the code used for fitting and experimenting with the pca
            - plotting: (irrelevant) code used for the plots of the thesis
    - report: this is the Latex project
    - Papaers: folder containing the paper I reference in my thesis
    - 5_models_full_scans_OG: models provided by Arbrea Labs
    - plys_OG: models provided by Arbrea Labs
    - screen_shots: screenshots used in thesis
        

